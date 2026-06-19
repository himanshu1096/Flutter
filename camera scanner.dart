import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// カメラの画像取得間隔の初期設定
/// (1秒にするとPCスペックによってはアプリ自体が立ち上がらないので注意)
const Duration _cameraInterval = Duration(seconds: 2);

/// カメラの詳細情報
// ハードウェアが変わらない限り変わらない (アプリ立ち上げ中は変わらない) ので、
// WidgetのStateでなくクラス外に変数として持つ
final List<CameraDescription> _cameras = <CameraDescription>[];

/// カメラの詳細情報を取得、設定する
Future<void> setCameraDescriptions() async {
  if (_cameras.isEmpty) {
    _cameras.addAll(await CameraPlatform.instance.availableCameras());
  }
}

/// カメラ画面のコントローラ
class CameraScannerController {
  /// カメラ画面のState
  late final _CameraScannerState _state;

  /// 初期化済みか
  final ValueNotifier<bool> isInitialized = ValueNotifier<bool>(false);

  /// Stateから呼び出してStateを登録する
  void _attach(_CameraScannerState state) {
    if (!isInitialized.value) {
      _state = state;
      isInitialized.value = true;
    }
  }

  /// カメラの変更が可能か
  Future<bool> get canSwitchCamera async {
    // カメラの詳細情報を取得
    await setCameraDescriptions();
    // 情報取得後に判定する
    return _cameras.length > 1;
  }

  /// 検知中か (初期化済みか確認してから使用してください)
  ValueNotifier<bool> get isDetecting => _state._isDetecting;

  /// カメラを変更する
  Future<CameraLensDirection> switchCamera({
    CameraLensDirection? direction,
  }) async {
    // レンズ方向からカメラ詳細情報を取得する
    final cameraDescription = _cameras.firstWhereOrNull(
      (x) => x.lensDirection == direction,
    );

    // カメラを変更する
    return await _state.switchCamera(cameraDescription);
  }

  /// 検知ループ開始
  Future<void> startDetection() async {
    await _state.startDetection();
  }

  /// 検知ループ停止
  Future<void> stopDetection() async {
    await _state.stopDetection();
  }

  void dispose() {
    _state._controller?.dispose();
  }
}

/// QRコード検知時の処理
/// rawBytes: バイナリQRデータ (Uint8List)
typedef DetectCallback = void Function(Uint8List rawBytes);

class CameraScanner extends StatefulWidget {
  /// カメラ画面
  const CameraScanner({
    super.key,
    this.controller,
    this.onDetected,
    this.lensDirection = CameraLensDirection.front,
    this.interval = _cameraInterval,
    this.displayResult = false,
  });

  /// カメラを操作するためのコントローラ
  final CameraScannerController? controller;

  /// 使用するレンズの向き（前面、背面、外付け）<br />
  /// (見つからなければ、最初に見つけたレンズでカメラを起動する)
  final CameraLensDirection lensDirection;

  /// コード検知時の処理
  final DetectCallback? onDetected;

  /// 画像検知の間隔
  final Duration interval;

  /// 結果を表示するか
  final bool displayResult;

  @override
  State<CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScanner> with RouteAware {
  /// カメラのコントローラ
  CameraController? _controller;

  /// 検出中か
  final ValueNotifier<bool> _isDetecting = ValueNotifier(false);

  /// デコーディング中か
  bool _isDecoding = false;

  /// QRコードに関するテキスト
  final ValueNotifier<String> _qrText = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    widget.controller?._attach(this);
  }

  @override
  void didPush() {
    // この画面がpushされたとき
    super.didPush();
    _initializeCamera();
  }

  @override
  void didPopNext() {
    // 上の画面がpopされて、この画面に戻ったとき
    super.didPopNext();
    _initializeCamera();
  }

  /// カメラを初期化する
  Future<void> _initializeCamera() async {
    await setCameraDescriptions();

    // コントローラがnullでなければ
    if (_controller case final _?) {
      // 初期化済みなので、処理を抜ける
    } else {
      // 起動するカメラを選択する
      final camera = _cameras.firstWhere(
        (x) => x.lensDirection == widget.lensDirection,
        orElse: () => _cameras.first,
      );

      // コントローラ作成
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // 初期化
      await _controller!.initialize();

      setState(() {
        // 検知ループ開始
        _startDetectionLoop();
      });
    }
  }

  /// 検知ループ開始
  void _startDetectionLoop() {
    _isDetecting.value = true;
    // 定期的に画像を取得してQR解析
    Timer.periodic(widget.interval, (timer) async {
      // 画面がなくなった、または、検出中でない
      if (!mounted || !_isDetecting.value) {
        // タイマーを停止
        timer.cancel();
        return;
      }

      // カメラ初期化済みか
      if (_controller case final controller?) {
        // QRコードの検知済み（デコード中）なら処理を抜ける
        if (_isDecoding) {
          return;
        }

        // デコード開始
        _isDecoding = true;
        // カメラ画像のファイル
        // (画面移動後に処理が走る場合など、
        // 画像ファイル取得失敗に対応できるようにnullableにする)
        XFile? imgFileOrNull;
        try {
          // カメラ画像をファイル化
          imgFileOrNull = await controller.takePicture();

          // 画像ファイルが取得出来たら
          if (imgFileOrNull case final imgFile) {
            // ファイルをバイトデータとして読込
            final bytes = await imgFile.readAsBytes();

            // バイトデータを画像に変換
            // (ファイルのヘッダ情報や圧縮情報を削除して画像化)
            if (img.decodeImage(bytes) case final image?) {
              final luminanceSource = RGBLuminanceSource(
                image.width,
                image.height,
                convertToInt32List(image),
              ); // RGBLuminanceSource

              final bitmap = BinaryBitmap(HybridBinarizer(luminanceSource));
              final reader = QRCodeReader();

              try {
                final result = reader.decode(bitmap);
                // バイナリデータを resultMetadata の byteSegments から取得
                // result.text は符号化問題があるため使用しない
                final byteSegments = result.resultMetadata?[
                  ResultMetadataType.byteSegments
                ];
                if (byteSegments != null &&
                    byteSegments is List &&
                    byteSegments.isNotEmpty) {
                  // 符号付き整数を符号なしバイトに変換
                  // 例: -121 & 0xFF = 135 = 0x87
                  final signedBytes = byteSegments[0] as List<int>;
                  final rawBytes = Uint8List.fromList(
                    signedBytes.map((b) => b & 0xFF).toList(),
                  );
                  debugPrint('QR byte length: ${rawBytes.length}');
                  _qrText.value = 'Bytes: ${rawBytes.length}';
                  // 検知時の処理を呼ぶ（バイナリデータを渡す）
                  widget.onDetected?.call(rawBytes);
                } else {
                  _qrText.value = 'QRコードなし';
                }
              } catch (e) {
                _qrText.value = 'QRコードなし';
              }
            } else {
              _qrText.value = "デコード失敗";
              _isDecoding = false;
            }
          }
        } on CameraException catch (e) {
          _qrText.value = 'カメラエラー: $e';
        } catch (e) {
          _qrText.value = 'エラー: $e';
        } finally {
          // カメラ画像があれば削除する
          if (imgFileOrNull case final imgFile?) {
            // XFileをio.Fileに変換
            final file = File(imgFile.path);
            // 画像ファイルがあれば、
            if (await file.exists()) {
              // ファイルを削除
              await file.delete();
            }
          }

          // 検知停止中なら値を削除する
          if (!_isDetecting.value) {
            _qrText.value = "";
          }

          _isDecoding = false;
        }
      }
    }); // Timer.periodic
  }

  /// 画像をInt32Listに型変換（ピクセルごとのRGB値を32bit整数に変換する）
  Int32List convertToInt32List(img.Image image) {
    final bytes = image.getBytes();
    final length = bytes.length ~/ 3;
    final pixels = Int32List(length);

    // ピクセルごとにRGB値を32bit整数に変換する
    for (var i = 0; i < length; i++) {
      final rIndex = i * 3;
      final r = bytes[rIndex];
      final g = bytes[rIndex + 1];
      final b = bytes[rIndex + 2];

      // ARGB形式（Alphaは255固定）
      pixels[i] = (0xFF << 24) | (r << 16) | (g << 8) | b;
    }

    return pixels;
  }

  @override
  void dispose() {
    // コントローラの後始末
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // コントローラがあれば
    if (_controller case final controller?) {
      return Stack(
        children: [
          // カメラのプレビュー表示
          LayoutBuilder(
            builder: (context, constraints) {
              // 縦横比を維持する
              final width = constraints.maxWidth;
              final height = width / controller.value.aspectRatio;
              return Center(
                child: Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: CameraPreview(controller),
                ), // Container
              ); // Center
            },
          ), // LayoutBuilder
          // QRコード、カメラ状態などを表示
          if (widget.displayResult)
            ValueListenableBuilder(
              valueListenable: _qrText,
              builder: (context, value, child) {
                return value.isNotEmpty
                    ? Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.black54,
                        ), // BoxDecoration
                        child: Text(
                          _qrText.value,
                          style: const TextStyle(color: Colors.white),
                        ), // Text
                      ), // Container
                    ) // Positioned
                    : const SizedBox.shrink();
              },
            ), // ValueListenableBuilder
          // カメラ停止中に暗幕をかける
          ValueListenableBuilder(
            valueListenable: _isDetecting,
            builder: (context, isDetecting, child) {
              return isDetecting
                  ? SizedBox.shrink()
                  : Positioned.fill(child: Container(color: Colors.black87));
            },
          ), // ValueListenableBuilder
        ],
      ); // Stack
    } else {
      // 準備中表示
      return const Center(child: CircularProgressIndicator());
    }
  }

  /// カメラを変更する
  Future<CameraLensDirection> switchCamera([
    CameraDescription? cameraDescription,
  ]) async {
    if (_controller case final controller?) {
      // カメラが1つより多ければ
      if (_cameras.length > 1) {
        // 次のカメラを取得
        final nextCamera = cameraDescription ?? _getNextCamera();

        // 次のカメラが現在のカメラと違ければ
        if (nextCamera != controller.description) {
          // カメラを変更する
          await controller.setDescription(nextCamera);
        }

        // 使用中のレンズを返して処理を抜ける
        return controller.description.lensDirection;
      } else {
        throw Exception("カメラのコントローラがnullです。:switchCamera()");
      }
    } else {
      throw Exception("カメラのコントローラがnullです。:switchCamera()");
    }
  }

  // 次のカメラを返す
  CameraDescription _getNextCamera() {
    if (_controller case final controller?) {
      final nextIndex = _cameras.indexOf(controller.description) + 1;
      return _cameras[nextIndex < _cameras.length ? nextIndex : 0];
    } else {
      throw Exception("カメラのコントローラがnullです。:_getNextCamera()");
    }
  }

  /// 検知ループ開始
  Future<void> startDetection() async {
    _startDetectionLoop();
    if (_controller case final controller?) {
      // プレビューを再開
      await controller.resumePreview();
    }
  }

  /// 検知ループ停止
  Future<void> stopDetection() async {
    _isDetecting.value = false;
    if (_controller case final controller?) {
      // プレビューを停止
      await controller.pausePreview();
    }
  }
}
