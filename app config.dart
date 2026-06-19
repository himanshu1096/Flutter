import 'dart:convert';
import 'dart:io';

import '../service/app_logger.dart';

/// アプリ設定
/// C:\tobu\config\app_config.json から読み込む
/// ファイルが存在しない場合はデフォルト値を使用
///
/// app_config.json の例:
/// {
///   "TCP_HOST": "127.0.0.1",
///   "TCP_PORT": 8080
/// }
class AppConfig {
  // シングルトン
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  static const String _configPath = r'C:\tobu\config\app_config.json';
  static const String _tag = 'AppConfig';

  // デフォルト値
  static const String _defaultHost = '127.0.0.1';
  static const int _defaultPort = 8080;

  String _host = _defaultHost;
  int _port = _defaultPort;

  String get host => _host;
  int get port => _port;

  /// 設定ファイル読み込み
  /// ファイルがない or 読み込み失敗 → デフォルト値を使用
  Future<void> load() async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) {
        AppLogger().warn(
          _tag,
          '設定ファイルが見つかりません: $_configPath — デフォルト値を使用 (host=$_defaultHost, port=$_defaultPort)',
        );
        return;
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      _host = json['TCP_HOST'] as String? ?? _defaultHost;
      _port = json['TCP_PORT'] as int? ?? _defaultPort;

      AppLogger().info(
        _tag,
        '設定ファイル読み込み完了: host=$_host, port=$_port',
      );
    } catch (e) {
      AppLogger().error(
        _tag,
        '設定ファイル読み込みエラー — デフォルト値を使用',
        e,
      );
    }
  }
}
