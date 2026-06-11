import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'login/login_page.dart';
import 'login/transiton_animation.dart';

/// 画面名のまとめ
enum Pages {
  /// ログイン画面
  login,

  /// 駅名スプラッシュ
  stationSplash,

  /// メイン（待機）画面
  main,
}

// QRカメラ再起動の為に使用
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// ルート設定（ジャーナル印刷の為に必要）
final routConfig = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: Pages.login.name,
      builder: (context, state) => const LoginPage(),
    ), // GoRoute
    GoRoute(
      path: '/${Pages.stationSplash}',
      name: Pages.stationSplash.name,
      pageBuilder: splashTransitionBuilder,
    ), // GoRoute
    GoRoute(
      path: '/${Pages.main}',
      name: Pages.main.name,
      // builder: (context, state) => const MyHomePage(),
      pageBuilder: mainTransitionBuilder,
    ), // GoRoute
  ],
  observers: [routeObserver],
); // GoRouter
