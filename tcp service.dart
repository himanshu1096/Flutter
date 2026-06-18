import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../model/init_data.dart';
import '../model/login_response.dart';
import 'packet_codec.dart';

/// TCP接続状態
enum TcpConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// TCPサービス
/// 本体制御との通信を管理する
class TcpService {
  // シングルトン
  static final TcpService _instance = TcpService._internal();
  factory TcpService() => _instance;
  TcpService._internal();

  // 接続設定（ダミー）
  static const String _host = '127.0.0.1';
  static const int _port = 8080;

  // ソケット
  Socket? _socket;

  // 受信バッファ
  final List<int> _buffer = [];

  // 接続状態
  TcpConnectionState _state = TcpConnectionState.disconnected;
  TcpConnectionState get state => _state;

  // ストリームコントローラ
  final _connectionStateController =
      StreamController<TcpConnectionState>.broadcast();
  final _packetController = StreamController<TcpPacket>.broadcast();

  /// 接続状態ストリーム
  Stream<TcpConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// 受信パケットストリーム
  Stream<TcpPacket> get packetStream => _packetController.stream;

  // 初期化データ
  InitData? _initData;
  InitData? get initData => _initData;

  // 初期化完了 Completer
  final Completer<InitData> _initCompleter = Completer<InitData>();
  Future<InitData> get initDataFuture => _initCompleter.future;

  // ログインレスポンス Completer
  Completer<LoginResponse>? _loginCompleter;

  /// TCP接続開始
  /// アプリ起動時に呼び出す — UIブロックしない
  Future<void> connect() async {
    if (_state == TcpConnectionState.connected) return;

    _setState(TcpConnectionState.connecting);

    try {
      _socket = await Socket.connect(_host, _port);
      _setState(TcpConnectionState.connected);

      // 受信リスナー設定
      _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _setState(TcpConnectionState.error);
      rethrow;
    }
  }

  /// データ受信処理
  void _onData(Uint8List data) {
    _buffer.addAll(data);

    // バッファからパケットを取り出す
    while (true) {
      final packet = TcpPacket.decode(_buffer);
      if (packet == null) break;

      // バッファから消費したバイトを削除
      final consumed = 8 + _getJsonLength(_buffer);
      _buffer.removeRange(0, consumed);

      // パケット処理
      _handlePacket(packet);
    }
  }

  /// バッファ先頭のJSONバイト数を取得
  int _getJsonLength(List<int> buffer) {
    if (buffer.length < 4) return 0;
    final byteData = ByteData.sublistView(Uint8List.fromList(buffer));
    return byteData.getUint32(0, Endian.big);
  }

  /// パケット処理
  void _handlePacket(TcpPacket packet) {
    // パケットストリームに流す
    _packetController.add(packet);

    switch (packet.commandId) {
      // 画面制御初期化要求 (0x0A81)
      case CommandId.initRequest:
        final initData = InitData.fromJson(packet.json);
        _initData = initData;
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete(initData);
        }
        break;

      // ログイン要求応答 (0xA181)
      case CommandId.loginResponse:
        final loginResponse = LoginResponse.fromJson(packet.json);
        _loginCompleter?.complete(loginResponse);
        _loginCompleter = null;
        break;

      // 業務強制取消通知 (0xFB81)
      case CommandId.forceCancelNotify:
        // QR読取ページへ戻る — UIレイヤーで処理
        break;

      // 本体制御異常通知 (0xFA81)
      case CommandId.systemErrorNotify:
        // エラーダイアログ — UIレイヤーで処理
        break;
    }
  }

  /// エラー処理
  void _onError(Object error) {
    _setState(TcpConnectionState.error);
  }

  /// 接続切断処理
  void _onDone() {
    _setState(TcpConnectionState.disconnected);
  }

  /// パケット送信
  Future<void> sendPacket({
    required int commandId,
    required Map<String, dynamic> json,
  }) async {
    if (_socket == null || _state != TcpConnectionState.connected) {
      throw Exception('TCP未接続');
    }
    final bytes = TcpPacket.encode(commandId: commandId, json: json);
    _socket!.add(bytes);
    await _socket!.flush();
  }

  /// 初期化完了通知送信 (0x0A01)
  Future<void> sendInitComplete({required bool result}) async {
    await sendPacket(
      commandId: CommandId.initComplete,
      json: {'INITIALIZERESULT': result},
    );
  }

  /// ログイン要求送信 (0xA101)
  /// レスポンスを Future で返す
  Future<LoginResponse> sendLoginRequest({
    required String id,
    required String password,
  }) async {
    _loginCompleter = Completer<LoginResponse>();
    await sendPacket(
      commandId: CommandId.loginRequest,
      json: {'ID': id, 'PASSWORD': password},
    );
    return _loginCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('ログイン応答タイムアウト'),
    );
  }

  /// 接続状態更新
  void _setState(TcpConnectionState state) {
    _state = state;
    _connectionStateController.add(state);
  }

  /// 切断
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    _setState(TcpConnectionState.disconnected);
  }

  /// リソース解放
  void dispose() {
    _socket?.destroy();
    _connectionStateController.close();
    _packetController.close();
  }
}
