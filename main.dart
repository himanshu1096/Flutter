import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gen/assets.gen.dart';
import 'provider/provider.dart';
import 'rout_config.dart';

void main() {
  // ライセンス登録
  LicenseRegistry.addLicense(() async* {
    // asset のライセンス情報ファイルを読み込む
    final license = await rootBundle.loadString(Assets.font.mPLUSRounded1c.ofl);
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(ProviderScope(child: const MyApp()));
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
