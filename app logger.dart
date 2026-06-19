import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// ファイル出力用ログフィルター
/// 全レベルを出力する
class _FileLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

/// ファイル出力用プリンター
/// フォーマット: [yyyy-MM-dd HH:mm:ss.SSS] [LEVEL] [TAG] MESSAGE
class _FilePrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final now = DateTime.now();
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);
    final levelStr = event.level.name.toUpperCase().padRight(5);
    final message = event.message.toString();
    return ['[$timeStr] [$levelStr] $message'];
  }
}

/// ファイル出力用アウトプット
class _FileOutput extends LogOutput {
  IOSink? sink;

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      sink?.writeln(line);
    }
  }
}

/// アプリケーションロガー
///
/// 使い方:
///   AppLogger().info('TcpService', 'TCP接続成功');
///   AppLogger().warn('Main', '設定ファイルが見つかりません');
///   AppLogger().error('Login', 'ログイン失敗', error);
///
/// ログファイル: C:\tobu\logs\nsscreen_YYYYMMDD.log
/// - 毎日新しいファイルを作成
/// - 3日以上古いログを自動削除
/// - debug モード: コンソールにも出力
class AppLogger {
  // シングルトン
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static const String _logDir = r'C:\tobu\logs';
  static const int _retentionDays = 3;

  Logger? _logger;
  final _fileOutput = _FileOutput();
  String? _currentLogDate;

  /// ロガー初期化 — アプリ起動時に一度だけ呼ぶ
  Future<void> init() async {
    await _deleteOldLogs();
    await _openLogFile();
    _buildLogger();
    info('AppLogger', 'ロガー初期化完了');
  }

  /// Loggerインスタンス構築
  void _buildLogger() {
    final outputs = <LogOutput>[_fileOutput];

    // デバッグモードではコンソールにも出力
    if (kDebugMode) {
      outputs.add(ConsoleOutput());
    }

    _logger = Logger(
      filter: _FileLogFilter(),
      printer: _FilePrinter(),
      output: MultiOutput(outputs),
    );
  }

  /// INFO ログ
  void info(String tag, String message) {
    _checkDateRotation();
    _logger?.i('[$tag] $message');
  }

  /// WARN ログ
  void warn(String tag, String message) {
    _checkDateRotation();
    _logger?.w('[$tag] $message');
  }

  /// ERROR ログ
  void error(String tag, String message, [Object? err]) {
    _checkDateRotation();
    final msg = err != null ? '$message — $err' : message;
    _logger?.e('[$tag] $msg');
  }

  /// 日付変わりチェック — 変わったら新しいファイルへ
  void _checkDateRotation() {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    if (_currentLogDate != today) {
      _openLogFile();
      _buildLogger();
    }
  }

  /// ログファイルを開く
  Future<void> _openLogFile() async {
    try {
      // 既存 sink を閉じる
      await _fileOutput.sink?.flush();
      await _fileOutput.sink?.close();
      _fileOutput.sink = null;

      _currentLogDate = DateFormat('yyyyMMdd').format(DateTime.now());

      final dir = Directory(_logDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final filePath = '$_logDir\\nsscreen_$_currentLogDate.log';
      _fileOutput.sink = File(filePath).openWrite(mode: FileMode.append);
    } catch (e) {
      debugPrint('ログファイルオープンエラー: $e');
    }
  }

  /// 3日以上古いログファイルを削除
  Future<void> _deleteOldLogs() async {
    try {
      final dir = Directory(_logDir);
      if (!await dir.exists()) return;

      final cutoff = DateTime.now().subtract(
        const Duration(days: _retentionDays),
      );

      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('nsscreen_')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            debugPrint('古いログファイルを削除: ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('古いログファイル削除エラー: $e');
    }
  }

  /// ロガー終了
  Future<void> dispose() async {
    await _fileOutput.sink?.flush();
    await _fileOutput.sink?.close();
    _fileOutput.sink = null;
    _logger?.close();
  }
}
