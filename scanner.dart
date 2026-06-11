import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_color.dart';
import 'camera_scanner.dart';
import 'provider/provider.dart';

class ScannerWidget extends ConsumerStatefulWidget {
  /// QRコード読み取りのカメラ画面
  const ScannerWidget({super.key});

  @override
  ConsumerState<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends ConsumerState<ScannerWidget> {
  /// カメラ画面のコントローラ
  final CameraScannerController _controller = CameraScannerController();

  @override
  Widget build(BuildContext context) {
    // カメラの方向
    final cameraDirection = ref.watch(currentCameraLensProvider);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColor.indigo.no700,
        title: const Text('読み取る'),
      ), // AppBar
      backgroundColor: Colors.black,
      body: CameraScanner(
        controller: _controller,
        lensDirection: cameraDirection,
        onDetected: (decodedText) {
          Navigator.of(context).pop(decodedText);
        },
      ), // CameraScanner
      floatingActionButton: FutureBuilder(
        future: _controller.canSwitchCamera,
        builder: (context, snapshot) {
          // データ取得完了、かつ、カメラ切り替え可能なら
          if (snapshot.hasData && (snapshot.data ?? false)) {
            // 切り替えボタンを表示
            return FloatingActionButton.large(
              backgroundColor: AppColor.indigo.no700,
              foregroundColor: Colors.white,
              onPressed: () async {
                // カメラ切り替え
                final currentDirection = await _controller.switchCamera();
                // 切り替え後のカメラ方向を記録
                ref
                    .read(currentCameraLensProvider.notifier)
                    .change(currentDirection);
              },
              child: Icon(Icons.cameraswitch_outlined),
            ); // FloatingActionButton.large
          }

          return SizedBox.shrink();
        },
      ), // FutureBuilder
    ); // Scaffold
  }
}
