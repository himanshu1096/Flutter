import 'dart:io';
import 'app_logger.dart';

/// CSVルックアップサービス
/// C:\tobu\csv\status_codes.csv から数値コードを文字列に変換
///
/// CSVフォーマット:
/// FIELDNAME,CODE,VALUE
/// MEDIATYPE,1,普通券
/// MEDIATYPE,2,企画券
class CsvService {
  static final CsvService _instance = CsvService._internal();
  factory CsvService() => _instance;
  CsvService._internal();

  static const String _csvPath = r'C:\tobu\csv\status_codes.csv';
  static const String _tag = 'CsvService';

  // キャッシュ: { FIELDNAME: { CODE: VALUE } }
  final Map<String, Map<int, String>> _cache = {};
  bool _loaded = false;

  /// CSV読み込み — アプリ起動時に一度だけ呼ぶ
  Future<void> load() async {
    if (_loaded) return;
    try {
      final file = File(_csvPath);
      if (!await file.exists()) {
        AppLogger().warn(_tag, 'CSVファイルが見つかりません: $_csvPath');
        return;
      }
      final lines = await file.readAsLines();
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(',');
        if (parts.length < 3) continue;
        final fieldName = parts[0].trim();
        final code = int.tryParse(parts[1].trim());
        final value = parts[2].trim();
        if (code == null) continue;
        _cache.putIfAbsent(fieldName, () => {})[code] = value;
      }
      _loaded = true;
      AppLogger().info(_tag, 'CSV読み込み完了: ${_cache.length}フィールド');
    } catch (e) {
      AppLogger().error(_tag, 'CSV読み込みエラー', e);
    }
  }

  /// 数値コードを文字列に変換
  /// 見つからない場合は数値をそのまま文字列で返す
  String lookup(String fieldName, int? code) {
    if (code == null) return '';
    return _cache[fieldName]?[code] ?? code.toString();
  }
}
