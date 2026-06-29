import 'dart:io';
import '../config/app_config.dart';
import 'app_logger.dart';

/// 処理完了音再生サービス
/// app_config.json の BEEP_SOUND_PATH から .wav ファイルを再生
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static const String _tag = 'SoundService';

  /// 処理完了音を再生
  Future<void> playComplete() async {
    try {
      final path = TcpConfig().beepSoundPath;
      final file = File(path);
      if (!await file.exists()) {
        AppLogger().warn(_tag, '音声ファイルが見つかりません: $path');
        return;
      }
      // Windows PowerShell で wav 再生
      await Process.run('powershell', [
        '-c',
        '(New-Object Media.SoundPlayer "$path").PlaySync()',
      ]);
      AppLogger().info(_tag, '処理完了音再生: $path');
    } catch (e) {
      AppLogger().error(_tag, '音声再生エラー', e);
    }
  }
}
