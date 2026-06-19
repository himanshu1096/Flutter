/// 画面制御初期化要求 (0x0A81) データモデル
/// JSONキー仕様:
///   PLACESTATION      : 設置駅名 (文字列)
///   CONNTESTRESULT    : QRモジュール通信確認結果 (Bool)
class InitData {
  final String stationName;
  final bool connectionTestResult;

  const InitData({
    required this.stationName,
    required this.connectionTestResult,
  });

  factory InitData.fromJson(Map<String, dynamic> json) {
    return InitData(
      stationName: json['PLACESTATION'] as String? ?? '',
      connectionTestResult: json['CONNTESTRESULT'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'InitData(stationName: $stationName, connectionTestResult: $connectionTestResult)';
}
