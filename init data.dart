/// 画面制御初期化要求 (0x0A81) のデータモデル
class InitData {
  final String stationName;
  final bool connectionTestResult;

  const InitData({
    required this.stationName,
    required this.connectionTestResult,
  });

  factory InitData.fromJson(Map<String, dynamic> json) {
    return InitData(
      stationName: json['STATIONNAME'] as String? ?? '',
      connectionTestResult: json['CONNECTIONTESTRESULT'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'InitData(stationName: $stationName, connectionTestResult: $connectionTestResult)';
}
