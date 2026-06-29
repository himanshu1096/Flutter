import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:qr_multidemo/app_config.dart';
import '../config/tcp_config.dart';
import '../model/init_data.dart';
import '../model/login_response.dart';
import '../model/qr_server_response.dart';
import 'app_logger.dart';
import 'packet_codec.dart';
import 'csv_service.dart';
import '../model/display_data.dart';
import '../model/process_response.dart';

/// TCP接続状態
enum TcpConnectionState { disconnected, connecting, connected, error }

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

  // QRサーバ照会レスポンス Completer
  Completer<QrServerResponse>? _qrCompleter;

  // 表示データ Completer (0x1281)
  Completer<DisplayData>? _displayDataCompleter;

  // 最後のQRデータ (0x1201再送用)
  int _lastDesignation = 1;
  List<int>? _lastRawData;
  String? _lastQrNumber;

  /// TCP通信開始
  /// 1. 受信ServerSocketをport 21002でLISTEN開始（専用Isolate）
  /// 2. 送信Socketをport 21001に接続
  Future<void> start() async {
    AppLogger().info(_tag, 'TCP開始');

    // Step 1: port 21002 でLISTEN開始
    await _startReceiveIsolate();

    // Step 2: port 21001 へ接続（バックグラウンドでリトライ）
    _connectSendSocketWithRetry();

    _setState(TcpConnectionState.connected);
  }

  /// 送信Socket接続 — 5秒間隔でリトライ
  Future<void> _connectSendSocketWithRetry() async {
    while (true) {
      try {
        await _connectSendSocket();
        AppLogger().info(_tag, '送信Socket接続成功');
        return;
      } catch (e) {
        AppLogger().warn(_tag, '送信Socket接続待機中... 5Ms後リトライ');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  /// 受信Isolate起動
  /// port 21002 で ServerSocket をLISTEN
  Future<void> _startReceiveIsolate() async {
    // AppLogger().info(_tag, '受信Isolate起動: port $_receivePort');

    _fromIsolatePort = ReceivePort();

    final config = _ReceiveIsolateConfig(
      mainSendPort: _fromIsolatePort!.sendPort,
      receivePort: _receivePort,
    );

    // Isolate起動
    _receiveIsolate = await Isolate.spawn(_receiveIsolateEntry, config);

    // Isolateからのメッセージを受信
    _fromIsolatePort!.listen((message) {
      if (message is List<int>) {
        // バイトデータ受信 → パケット解析
        _handleReceivedBytes(message);
      } else if (message is String) {
        // ログメッセージ
        //  AppLogger().info('ReceiveIsolate', message);
      }
    });

    AppLogger().info(_tag, '受信Isolate起動完了: port $_receivePort LISTENING');
  }

  /// 受信Isolateエントリーポイント
  /// メインIsolateとは別スレッドで動作
  static Future<void> _receiveIsolateEntry(_ReceiveIsolateConfig config) async {
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
          // 受信生データをhexでログ出力
          final hexStr = data
              .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(' ');
          sendPort.send('受信生データ (${data.length}bytes): $hexStr');
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
          setTcpStationName(initData.stationName);
          if (!_initCompleter.isCompleted) {
            _initCompleter.complete(initData);
          }
        } catch (e) {
          AppLogger().error(_tag, '0x0A81 JSONパースエラー', e);
        }
        break;

      // QRサーバ照会要求応答 (0x1181) Server → Flutter
      case CommandId.qrServerRefResponse:
        AppLogger().info(_tag, '0x1181 QRサーバ照会要求応答 受信');
        try {
          final qrResponse = QrServerResponse.fromJson(packet.json);
          AppLogger().info(
            _tag,
            'QR照会応答: RESULT=${qrResponse.result}, ERRCODE=${qrResponse.errCode}',
          );
          _qrCompleter?.complete(qrResponse);
          _qrCompleter = null;
        } catch (e) {
          AppLogger().error(_tag, '0x1181 JSONパースエラー', e);
          _qrCompleter?.completeError(e);
          _qrCompleter = null;
        }
        break;

      // 表示データ応答 (0x1281) Server → Flutter
      case CommandId.displayDataResponse:
        AppLogger().info(_tag, '0x1281 表示データ応答 受信');
        try {
          final displayData = DisplayData.fromJson(packet.json);
          AppLogger().info(_tag, '表示データ解析完了: QRNUMBER=${displayData.qrNumber}');
          _displayDataCompleter?.complete(displayData);
          _displayDataCompleter = null;
        } catch (e) {
          AppLogger().error(_tag, '0x1281 JSONパースエラー', e);
          _displayDataCompleter?.completeError(e);
          _displayDataCompleter = null;
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

      // 入場処理実行要求応答 (0x2181)
      case CommandId.enterResponse:
      // 出場処理実行要求応答 (0x2281)
      case CommandId.exitResponse:
      // 精算処理実行要求応答 (0x2381)
      case CommandId.adjustResponse:
      // 廃券処理実行要求応答 (0x2481)
      case CommandId.cancelTicketResponse:
      // 発駅キャンセル実行要求応答 (0x2581)
      case CommandId.enterCancelResponse:
        AppLogger().info(_tag, '業務処理応答 受信: $cmdHex');
        try {
          final response = ProcessResponse.fromJson(packet.json);
          _processCompleter?.complete(response);
          _processCompleter = null;
        } catch (e) {
          AppLogger().error(_tag, '業務処理応答 パースエラー', e);
          _processCompleter?.completeError(e);
          _processCompleter = null;
        }
        break;

      // 業務取消要求応答 (0xB181)
      case CommandId.cancelResponse:
        AppLogger().info(_tag, '0xB181 業務取消応答 受信');
        try {
          final response = ProcessResponse.fromJson(packet.json);
          _cancelCompleter?.complete(response);
          _cancelCompleter = null;
        } catch (e) {
          AppLogger().error(_tag, '0xB181 パースエラー', e);
          _cancelCompleter?.completeError(e);
          _cancelCompleter = null;
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
        AppLogger().warn(_tag, '未処理コマンド受信: $cmdHex');
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

  /// QRサーバ照会要求送信 (0x1101) Flutter → Server
  /// designation = 1: QRデータ (バイナリ66bytes)
  /// designation = 2: QRチケット番号 (文字列)
  Future<QrServerResponse> sendQrServerRequest({
    required int designation,
    Uint8List? rawData,
    String? qrNumber,
  }) async {
    AppLogger().info(_tag, '0x1101 QRサーバ照会要求 送信: QRDESIGNATION=$designation');

    final Map<String, dynamic> json = {'QRDESIGNATION': designation};

    if (designation == 1 && rawData != null) {
      // バイナリデータを符号なし整数配列として送信 (0-255)
      // Uint8List の値は既に符号なし (0-255) なので toList() でそのまま使用可能
      json['QRRAWDATA'] = rawData.toList();
      final hexStr = rawData
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(' ');
      AppLogger().info(_tag, 'QRRAWDATAバイト数: ${rawData.length}');
      AppLogger().info(_tag, 'QRRAWDATA hex: $hexStr');
    } else if (designation == 2 && qrNumber != null) {
      json['QRNUMBER'] = qrNumber;
      AppLogger().info(_tag, 'QRNUMBER: $qrNumber');
    }

    // 0x1201再送用に保存
    _lastDesignation = designation;
    if (designation == 1 && rawData != null) {
      _lastRawData = rawData.toList();
      _lastQrNumber = null;
    } else if (designation == 2 && qrNumber != null) {
      _lastQrNumber = qrNumber;
      _lastRawData = null;
    }

    _qrCompleter = Completer<QrServerResponse>();
    await sendPacket(commandId: CommandId.qrServerRefRequest, json: json);

    return _qrCompleter!.future.timeout(
      const Duration(seconds: 180),
      onTimeout: () {
        AppLogger().error(_tag, 'QR照会応答タイムアウト (180秒)');
        _qrCompleter = null;
        throw TimeoutException('QR照会応答タイムアウト');
      },
    );
  }

  /// 表示データ要求送信 (0x1201) Flutter → Server
  /// 0x1101と同じQRデータを再送
  Future<DisplayData> sendDisplayDataRequest() async {
    AppLogger().info(_tag, '0x1201 表示データ要求 送信');

    final Map<String, dynamic> json = {'QRDESIGNATION': _lastDesignation};
    if (_lastDesignation == 1 && _lastRawData != null) {
      json['QRRAWDATA'] = _lastRawData;
    } else if (_lastDesignation == 2 && _lastQrNumber != null) {
      json['QRNUMBER'] = _lastQrNumber;
    }

    _displayDataCompleter = Completer<DisplayData>();
    await sendPacket(commandId: CommandId.displayDataRequest, json: json);

    return _displayDataCompleter!.future.timeout(
      const Duration(seconds: 180),
      onTimeout: () {
        AppLogger().error(_tag, '表示データ応答タイムアウト (180秒)');
        _displayDataCompleter = null;
        throw TimeoutException('表示データ応答タイムアウト');
      },
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
