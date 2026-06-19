import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../config/app_config.dart';
import '../model/init_data.dart';
import '../model/login_response.dart';
import 'app_logger.dart';
import 'packet_codec.dart';

/// TCP接続状態
enum TcpConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// TCPサービス
/// 本体制御との通信を管理するシングルトン
class TcpService {
  static final TcpService _instance = TcpService._internal();
  factory TcpService() => _instance;
  TcpService._internal();

  static const String _tag = 'TcpService';

  // 設定はAppConfigから取得（外部ファイルで変更可能）
  String get _host => AppConfig().host;
  int get _port => AppConfig().port;

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
  /// アプリ起動時に呼び出す — UIをブロックしない
  Future<void> connect() async {
    if (_state == TcpConnectionState.connected) return;

    _setState(TcpConnectionState.connecting);
    AppLogger().info(_tag, 'TCP接続開始: $_host:$_port');

    try {
      _socket = await Socket.connect(_host, _port);
      _setState(TcpConnectionState.connected);
      AppLogger().info(_tag, 'TCP接続成功: $_host:$_port');
      AppLogger().info(_tag, '0x0A81 (画面制御初期化要求) 待機中...');

      // 受信リスナー設定
      _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _setState(TcpConnectionState.error);
      AppLogger().error(_tag, 'TCP接続失敗: $_host:$_port', e);
      rethrow;
    }
  }

  /// データ受信処理
  void _onData(Uint8List data) {
    _buffer.addAll(data);

    // バッファからパケットを取り出す（複数パケットが一度に来る場合も対応）
    while (true) {
      final packet = TcpPacket.decode(_buffer);
      if (packet == null) break;

      // バッファから消費したバイトを削除（6 = 4 length + 2 cmdID）
      final consumed = 6 + TcpPacket.getJsonLength(_buffer);
      _buffer.removeRange(0, consumed);

      // パケット処理
      _handlePacket(packet);
    }
  }

  /// パケット処理
  void _handlePacket(TcpPacket packet) {
    final cmdHex = '0x${packet.commandId.toRadixString(16).toUpperCase()}';
    AppLogger().info(_tag, 'パケット受信: $cmdHex');

    // パケットストリームに流す（UIレイヤーでも購読可能）
    _packetController.add(packet);

    switch (packet.commandId) {

      // 画面制御初期化要求 (0x0A81) — Server → Flutter
      case CommandId.initRequest:
        AppLogger().info(_tag, '0x0A81 画面制御初期化要求 受信');
        try {
          final initData = InitData.fromJson(packet.json);
          _initData = initData;
          AppLogger().info(
            _tag,
            '初期化データ解析完了: 駅名=${initData.stationName}, 通信確認=${initData.connectionTestResult}',
          );
          if (!_initCompleter.isCompleted) {
            _initCompleter.complete(initData);
          }
        } catch (e) {
          AppLogger().error(_tag, '0x0A81 JSONパースエラー', e);
        }
        break;

      // ログイン要求応答 (0xA181) — Server → Flutter
      case CommandId.loginResponse:
        AppLogger().info(_tag, '0xA181 ログイン要求応答 受信');
        try {
          final loginResponse = LoginResponse.fromJson(packet.json);
          AppLogger().info(
            _tag,
            'ログイン応答: RESULT=${loginResponse.result}, AUTHORITY=${loginResponse.authority}',
          );
          _loginCompleter?.complete(loginResponse);
          _loginCompleter = null;
        } catch (e) {
          AppLogger().error(_tag, '0xA181 JSONパースエラー', e);
          _loginCompleter?.completeError(e);
          _loginCompleter = null;
        }
        break;

      // 接続状態変化通知 (0xF181) — Server → Flutter
      case CommandId.connectionStatusNotify:
        AppLogger().warn(_tag, '0xF181 接続状態変化通知 受信');
        // UIレイヤーで処理（3つのボタンの制御）
        break;

      // 本体制御異常通知 (0xFA81) — Server → Flutter
      case CommandId.systemErrorNotify:
        AppLogger().error(_tag, '0xFA81 本体制御異常通知 受信');
        // UIレイヤーで処理（エラーダイアログ表示）
        break;

      // 業務強制取消通知 (0xFB81) — Server → Flutter
      case CommandId.forceCancelNotify:
        AppLogger().warn(_tag, '0xFB81 業務強制取消通知 受信');
        // UIレイヤーで処理（QR読取ページへ戻る）
        break;

      default:
        AppLogger().warn(_tag, '未処理コマンド受信: $cmdHex');
        break;
    }
  }

  /// エラー処理
  void _onError(Object error) {
    AppLogger().error(_tag, 'TCP通信エラー', error);
    _setState(TcpConnectionState.error);
  }

  /// 接続切断処理
  void _onDone() {
    AppLogger().warn(_tag, 'TCP接続切断');
    _setState(TcpConnectionState.disconnected);
  }

  /// パケット送信
  Future<void> sendPacket({
    required int commandId,
    required Map<String, dynamic> json,
  }) async {
    if (_socket == null || _state != TcpConnectionState.connected) {
      AppLogger().error(_tag, 'パケット送信失敗: TCP未接続');
      throw Exception('TCP未接続');
    }

    final cmdHex = '0x${commandId.toRadixString(16).toUpperCase()}';
    AppLogger().info(_tag, 'パケット送信: $cmdHex');

    final bytes = TcpPacket.encode(commandId: commandId, json: json);
    _socket!.add(bytes);
    await _socket!.flush();

    AppLogger().info(_tag, 'パケット送信完了: $cmdHex');
  }

  /// 初期化完了通知送信 (0x0A01) — Flutter → Server
  Future<void> sendInitComplete({required bool result}) async {
    AppLogger().info(_tag, '0x0A01 初期化完了通知 送信');
    await sendPacket(
      commandId: CommandId.initComplete,
      json: {'INITIALIZERESULT': result},
    );
  }

  /// ログイン要求送信 (0xA101) — Flutter → Server
  /// レスポンスを Future で返す、タイムアウト180秒
  Future<LoginResponse> sendLoginRequest({
    required String id,
    required String password,
  }) async {
    AppLogger().info(_tag, '0xA101 ログイン要求 送信: ID=$id');
    _loginCompleter = Completer<LoginResponse>();
    await sendPacket(
      commandId: CommandId.loginRequest,
      json: {'LOGINID': id, 'LOGINPASSWORD': password},
    );
    return _loginCompleter!.future.timeout(
      const Duration(seconds: 180),
      onTimeout: () {
        AppLogger().error(_tag, 'ログイン応答タイムアウト (180秒)');
        throw TimeoutException('ログイン応答タイムアウト');
      },
    );
  }

  /// 接続状態更新
  void _setState(TcpConnectionState newState) {
    _state = newState;
    _connectionStateController.add(newState);
  }

  /// 切断
  Future<void> disconnect() async {
    AppLogger().info(_tag, 'TCP切断');
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
