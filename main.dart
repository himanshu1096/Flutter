import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'camera_scanner.dart';
import 'config/tcp_config.dart';
import 'gen/assets.gen.dart';
import 'provider/provider.dart';
import 'rout_config.dart';
import 'service/app_logger.dart';
import 'service/csv_service.dart';
import 'service/tcp_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  windowManager.ensureInitialized();
  await AppLogger().init();

  // ── CSV読み込み ─────────────────────────────────────
  await CsvService().load();
  AppLogger().info('Main', 'アプリ起動開始');
  // 表示可能まで待機
  await windowManager.waitUntilReadyToShow();

  // フルスクリーン化
  await windowManager.setFullScreen(false);
  // 枠（タイトルバー）を消す
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  // ライセンス登録
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(Assets.font.mPLUSRounded1c.ofl);
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  // ── 設定ファイル読み込み ──────────────────────────────
  await TcpConfig().load();
  // ── TCP接続開始（UIをブロックしない）─────────────────

  final tcpService = TcpService();
  try {
    await tcpService.start();
    //AppLogger().info('Main', 'TCP受信準備完了 port:21002');
  } catch (e) {
    AppLogger().error('Main', 'TCP起動失敗', e);
  }

  // ── 0x0A81 (画面制御初期化要求) 待機 ─────────────────
  // ※ UIはまだ表示されていない — サーバーからの通知を待つ
  AppLogger().info('Main', '0x0A81 待機中...');
  final initData = await tcpService.initDataFuture;
  AppLogger().info(
    'Main',
    '初期化完了: 駅名=${initData.stationName}, 通信確認=${initData.connectionTestResult}',
  );
  // ── カメラアクセス確認 ────────────────────────────────

  await _checkCameraAccessible();

  // ── アプリ起動 ────────────────────────────────────────
  // TcpServiceシングルトンに initData が保持されているため
  // ProviderScope への override は不要
  AppLogger().info('Main', 'ログインページ表示');
  runApp(const ProviderScope(child: MyApp()));
}

/// カメラアクセス確認
/// カメラが実際に使用可能か初期化を試みる
Future<void> _checkCameraAccessible() async {
  try {
    await setCameraDescriptions();
    final cameras = await CameraPlatform.instance.availableCameras();
    if (cameras.isEmpty) {
      AppLogger().warn('Main', 'カメラが見つかりません');
      return;
    }
    // 実際に初期化して確認
    // final controller = CameraController(cameras.first, ResolutionPreset.low);
    // await controller.initialize();
    // await controller.dispose();
    // AppLogger().info('Main', 'カメラアクセス確認OK: ${cameras.length}台検出');
  } catch (e) {
    AppLogger().error('Main', 'カメラアクセスエラー', e);
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);

    return MaterialApp.router(
      routerConfig: routConfig,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', 'JP')],
      title: 'Flutter Demo',
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
    ); // MaterialApp.router
  }
}
