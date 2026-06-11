import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app_theme.dart';
import '../qr_process/secondary_tab_content_unselected.dart';
import '../utility/confirm_dialog.dart';

part 'provider.g.dart';

// QRチケット番号
@Riverpod(keepAlive: true)
class QrTicketNo extends _$QrTicketNo {
  @override
  String build() => '012345 6789 0123 4567 8910';

  void changeNo(String no) {
    state = no;
  }

  void reset() {
    state = '012345 6789 0123 4567 8910';
  }
}

// QR読み取りページで選択中のボタン
@riverpod
class QrReadPageSelectedBtn extends _$QrReadPageSelectedBtn {
  @override
  QrReadPageBtnKind build() => QrReadPageBtnKind.zyouhoHyouzi;

  void changePage(QrReadPageBtnKind kind) {
    state = kind;
  }
}

/// カメラの方向
@Riverpod(keepAlive: true) // アプリ起動中値を維持するため、keepAlive: true
class CurrentCameraLens extends _$CurrentCameraLens {
  @override
  CameraLensDirection build() => CameraLensDirection.front;

  /// カメラの方向を変更する
  void change(CameraLensDirection direction) {
    state = direction;
  }
}

// 印刷処理の進行度
@riverpod
class PrintingProgress extends _$PrintingProgress {
  @override
  PrintingStatus build() => PrintingStatus.start;

  void changeProgress(PrintingStatus progress) {
    state = progress;
  }
}

/// 適用中のテーマデータ
@riverpod
class CurrentTheme extends _$CurrentTheme {
  @override
  ThemeData build() => ThemeColors.orange.theme;

  /// テーマデータを設定する
  void set(ThemeData themeData) {
    state = themeData;
  }
}
