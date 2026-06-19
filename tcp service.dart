import 'dart:async';
import 'dart:io';
import 'dart:isolate';
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

/// 受信Isolateへの設定データ
class _ReceiveIsolateConfig {
  final SendPort mainSendPort;
  final int receivePort;

  const _ReceiveIsolateConfig({
    required this.mainSendPort,
    required this.receivePort,
  });
}

/// TCPサービス
/// 
/// 通信構成:
///   受信: nsscreen が ServerSocket で port 21002 をLISTEN
///         → メインモジュールが接続してきてコマンドを送信
///         → 専用Isolateで常時受信
///   
///   送信: nsscreen が Socket.connect() で port 21001 に接続
///         → メインモジュールへコマンドを送信
class TcpService {
  // シングルトン
  static final TcpService _instance = TcpService._internal();
  factory TcpService() => _instance;
  TcpService._internal();

  static const String _tag = 'TcpService';

  // 設定はTcpConfigから取得（外部ファイルで変更可能）
  String get _host => TcpConfig().host;
  int get _receivePort => TcpConfig().receivePort;
  int get _sendPort => TcpConfig().sendPort;

  // 送信用ソケット（Flutter → Main module）
  Socket? _sendSocket;

  // 受信用Isolate
  Isolate? _receiveIsolate;
  ReceivePort? _fromIsolatePort;

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

  /// TCP通信開始
  /// 1. 受信ServerSocketをport 21002でLISTEN開始（専用Isolate）
  /// 2. 送信Socketをport 21001に接続
  Future<void> start() async {
    _setState(TcpConnectionState.connecting);
    AppLogger().info(_tag, 'TCP通信開始');

    try {
      // ── Step 1: 受信Isolate起動（先にLISTENING状態にする）──
      await _startReceiveIsolate();

      // ── Step 2: 送信Socket接続 ────────────────────────────
      await _connectSendSocket();

      _setState(TcpConnectionState.connected);
      AppLogger().info(_tag, 'TCP通信準備完了');
      AppLogger().info(_tag, '0x0A81 (画面制御初期化要求) 待機中...');
    } catch (e) {
      _setState(TcpConnectionState.error);
      AppLogger().error(_tag, 'TCP通信開始失敗', e);
      rethrow;
    }
  }

  /// 受信Isolate起動
  /// port 21002 で ServerSocket をLISTEN
  Future<void> _startReceiveIsolate() async {
    AppLogger().info(_tag, '受信Isolate起動: port $_receivePort');

    _fromIsolatePort = ReceivePort();

    final config = _ReceiveIsolateConfig(
      mainSendPort: _fromIsolatePort!.sendPort,
      receivePort: _receivePort,
    );

    // Isolate起動
    _receiveIsolate = await Isolate.spawn(
      _receiveIsolateEntry,
      config,
    );

    // Isolateからのメッセージを受信
    _fromIsolatePort!.listen((message) {
      if (message is List<int>) {
        // バイトデータ受信 → パケット解析
        _handleReceivedBytes(message);
      } else if (message is String) {
        // ログメッセージ
        AppLogger().info('ReceiveIsolate', message);
      }
    });

    AppLogger().info(_tag, '受信Isolate起動完了: port $_receivePort LISTENING');
  }

  /// 受信Isolateエントリーポイント
  /// メインIsolateとは別スレッドで動作
  static Future<void> _receiveIsolateEntry(
    _ReceiveIsolateConfig config,
  ) async {
    final sendPort = config.mainSendPort;

    try {
      // ServerSocket でLISTEN
      final serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        config.receivePort,
      );
      sendPort.send('ServerSocket LISTEN開始: port ${config.receivePort}');

      // メインモジュールからの接続を待つ
      await for (final socket in serverSocket) {
        sendPort.send('メインモジュール接続: ${socket.remoteAddress.address}');

        // 受信バッファ
        final buffer = <int>[];

        // 受信ループ — 常時受信
        await for (final data in socket) {
          buffer.addAll(data);

          // バッファからパケットを取り出す
          while (buffer.length >= 6) {
            final jsonLength = TcpPacket.getJsonLength(buffer);
            if (buffer.length < 6 + jsonLength) break;

            // 完全なパケットをメインIsolateに送信
            final packetBytes = buffer.sublist(0, 6 + jsonLength);
            buffer.removeRange(0, 6 + jsonLength);
            sendPort.send(packetBytes);
          }
        }
        sendPort.send('メインモジュール切断');
      }
    } catch (e) {
      sendPort.send('受信Isolateエラー: $e');
    }
  }

  /// 受信バイト列を処理
  void _handleReceivedBytes(List<int> bytes) {
    final packet = TcpPacket.decode(bytes);
    if (packet == null) {
      AppLogger().warn(_tag, '不正パケット受信');
      return;
    }
    _handlePacket(packet);
  }

  /// 送信Socket接続
  /// port 21001 のメインモジュールに接続
  Future<void> _connectSendSocket() async {
    AppLogger().info(_tag, '送信Socket接続開始: $_host:$_sendPort');
    _sendSocket = await Socket.connect(_host, _sendPort);
    AppLogger().info(_tag, '送信Socket接続成功: $_host:$_sendPort');

    // 送信socket のエラー/切断を監視
    _sendSocket!.listen(
      (_) {}, // 送信socketでは受信しない
      onError: (e) {
        AppLogger().error(_tag, '送信Socket エラー', e);
        _setState(TcpConnectionState.error);
      },
      onDone: () {
        AppLogger().warn(_tag, '送信Socket 切断');
        _setState(TcpConnectionState.disconnected);
      },
    );
  }

  /// パケット処理
  void _handlePacket(TcpPacket packet) {
    final cmdHex = '0x${packet.commandId.toRadixString(16).toUpperCase()}';
    AppLogger().info(_tag, 'パケット受信: $cmdHex');

    // パケットストリームに流す（UIレイヤーでも購読可能）
    _packetController.add(packet);

    switch (packet.commandId) {

      // 画面制御初期化要求 (0x0A81) Server → Flutter
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

      // ログイン要求応答 (0xA181) Server → Flutter
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

      // 接続状態変化通知 (0xF181) Server → Flutter
      case CommandId.connectionStatusNotify:
        AppLogger().warn(_tag, '0xF181 接続状態変化通知 受信');
        // UIレイヤーで処理（3つのボタン制御）
        break;

      // 本体制御異常通知 (0xFA81) Server → Flutter
      case CommandId.systemErrorNotify:
        AppLogger().error(_tag, '0xFA81 本体制御異常通知 受信');
        // UIレイヤーで処理（エラーダイアログ）
        break;

      // 業務強制取消通知 (0xFB81) Server → Flutter
      case CommandId.forceCancelNotify:
        AppLogger().warn(_tag, '0xFB81 業務強制取消通知 受信');
        // UIレイヤーで処理（QR読取ページへ戻る）
        break;

      default:
        AppLogger().warn(
          _tag,
          '未処理コマンド受信: $cmdHex',
        );
        break;
    }
  }

  /// パケット送信（Flutter → Main module）
  Future<void> sendPacket({
    required int commandId,
    required Map<String, dynamic> json,
  }) async {
    if (_sendSocket == null || _state != TcpConnectionState.connected) {
      AppLogger().error(_tag, 'パケット送信失敗: 送信Socket未接続');
      throw Exception('送信Socket未接続');
    }

    final cmdHex = '0x${commandId.toRadixString(16).toUpperCase()}';
    AppLogger().info(_tag, 'パケット送信: $cmdHex');

    final bytes = TcpPacket.encode(commandId: commandId, json: json);
    _sendSocket!.add(bytes);
    await _sendSocket!.flush();

    AppLogger().info(_tag, 'パケット送信完了: $cmdHex');
  }

  /// 初期化完了通知送信 (0x0A01) Flutter → Server
  Future<void> sendInitComplete({required bool result}) async {
    AppLogger().info(_tag, '0x0A01 初期化完了通知 送信');
    await sendPacket(
      commandId: CommandId.initComplete,
      json: {'INITIALIZERESULT': result},
    );
  }

  /// ログイン要求送信 (0xA101) Flutter → Server
  /// タイムアウト180秒
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

  /// TCP通信停止
  Future<void> stop() async {
    AppLogger().info(_tag, 'TCP通信停止');

    // 受信Isolate停止
    _receiveIsolate?.kill(priority: Isolate.immediate);
    _receiveIsolate = null;
    _fromIsolatePort?.close();
    _fromIsolatePort = null;

    // 送信Socket切断
    await _sendSocket?.close();
    _sendSocket = null;

    _setState(TcpConnectionState.disconnected);
    AppLogger().info(_tag, 'TCP通信停止完了');
  }

  /// リソース解放
  void dispose() {
    _receiveIsolate?.kill(priority: Isolate.immediate);
    _sendSocket?.destroy();
    _connectionStateController.close();
    _packetController.close();
  }
}
