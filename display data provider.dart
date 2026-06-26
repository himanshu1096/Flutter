import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/display_data.dart';

part 'display_data_provider.g.dart';

/// 表示データプロバイダー (0x1281)
@Riverpod(keepAlive: true)
class DisplayDataNotifier extends _$DisplayDataNotifier {
  @override
  DisplayData? build() => null;

  void set(DisplayData data) => state = data;
  void clear() => state = null;
}

/// 最後のQRデータ保持 (0x1201再送用)
@Riverpod(keepAlive: true)
class LastQrData extends _$LastQrData {
  @override
  _LastQrDataState? build() => null;

  void setRawData(Uint8List rawData) =>
      state = _LastQrDataState(designation: 1, rawData: rawData);

  void setQrNumber(String qrNumber) =>
      state = _LastQrDataState(designation: 2, qrNumber: qrNumber);

  void clear() => state = null;
}

/// QRデータの状態
class _LastQrDataState {
  final int designation;
  final Uint8List? rawData;
  final String? qrNumber;

  const _LastQrDataState({
    required this.designation,
    this.rawData,
    this.qrNumber,
  });
}
