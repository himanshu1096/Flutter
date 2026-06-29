import 'dart:convert';
import 'dart:io';

import '../service/app_logger.dart';

/// TCP設定
/// C:\tobu\config\app_config.json から読み込む
///
/// app_config.json の例:
/// {
///   "TCP_HOST": "127.0.0.1",
///   "TCP_RECEIVE_PORT": 21002,
///   "TCP_SEND_PORT": 21001
/// }
class TcpConfig {
  // シングルトン
  static final TcpConfig _instance = TcpConfig._internal();
  factory TcpConfig() => _instance;
  TcpConfig._internal();

  static const String _configPath =
      'E:/NS/FK/App/NsScreen/config/app_config.json';
  static const String _tag = 'TcpConfig';

  // デフォルト値
  static const String _defaultHost = '127.0.0.1';
  static const int _defaultReceivePort = 21002; // nsscreen LISTEN
  static const int _defaultSendPort = 21001; // main module LISTEN
  static const String _defaultLogDir = 'E:/FK_DATA/Log';
  static const String _defaultBeepSoundPath = 'C:/tobu/sounds/complete.wav';
  // static const int _defaultinitCompleteDelayMs = 500;

  String _host = _defaultHost;
  int _receivePort = _defaultReceivePort;
  int _sendPort = _defaultSendPort;
  String _logDir = _defaultLogDir;
  String _beepSoundPath = _defaultBeepSoundPath;
  //int _initCompleteDelayMs = _defaultinitCompleteDelayMs;

  String get host => _host;
  int get receivePort => _receivePort;
  int get sendPort => _sendPort;
  String get logDir => _logDir;
  String get beepSoundPath => _beepSoundPath;
  //int get initCompleteDelayMs => _initCompleteDelayMs;

  /// 設定ファイル読み込み
  Future<void> load() async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) {
        AppLogger().warn(
          _tag,
          '設定ファイルが見つかりません: $_configPath — デフォルト値を使用 '
          '(host=$_defaultHost, receivePort=$_defaultReceivePort, sendPort=$_defaultSendPort)',
        );
        return;
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      _host = json['TCP_HOST'] as String? ?? _defaultHost;
      _receivePort = json['TCP_RECEIVE_PORT'] as int? ?? _defaultReceivePort;
      _sendPort = json['TCP_SEND_PORT'] as int? ?? _defaultSendPort;
      _logDir = json['LOG_DIR'] as String? ?? _defaultLogDir;
      _beepSoundPath = json['BEEP_SOUND_PATH'] as String? ?? _defaultBeepSoundPath;
      //_initCompleteDelayMs = json['INIT_COMPLETE_DELAY_MS'] as int? ?? 500;

      AppLogger().info(
        _tag,
        '設定読み込み完了: host=$_host, receivePort=$_receivePort, sendPort=$_sendPort',
      );
    } catch (e) {
      AppLogger().error(_tag, '設定ファイル読み込みエラー — デフォルト値を使用', e);
    }
  }
}
