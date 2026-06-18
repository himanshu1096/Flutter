import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_scanner.dart';
import 'gen/assets.gen.dart';
import 'provider/provider.dart';
import 'provider/tcp_provider.dart';
import 'rout_config.dart';
import 'service/tcp_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ライセンス登録
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(Assets.font.mPLUSRounded1c.ofl);
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  // TCPサービス取得
  final tcpService = TcpService();

  // TCP接続開始（バックグラウンド — UIをブロックしない）
  tcpService.connect().catchError((e) {
    debugPrint('TCP接続エラー: $e');
  });

  // カメラアクセス確認
  await _checkCameraAccessible();

  // 初期化要求を待つ（0x0A81）
  // ※ UIはまだ表示されていない
  final initData = await tcpService.initDataFuture;
  debugPrint('初期化データ受信: $initData');

  // アプリ起動
  runApp(
    ProviderScope(
      overrides: [
        // 初期化データをプロバイダーに設定
        initDataProvider.overrideWith((ref) => initData),
      ],
      child: const MyApp(),
    ),
  );
}

/// カメラアクセス確認
Future<void> _checkCameraAccessible() async {
  try {
    await setCameraDescriptions();
    debugPrint('カメラアクセス確認OK');
  } catch (e) {
    debugPrint('カメラアクセスエラー: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // テーマの変更を監視
    final currentTheme = ref.watch(currentThemeProvider);

    return MaterialApp.router(
      routerConfig: routConfig,
      //================================ 言語設定の日本語化 ここから
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', 'JP')],
      //================================ 言語設定の日本語化 ここまで
      title: 'Flutter Demo',
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
    ); // MaterialApp.router
  }
}
