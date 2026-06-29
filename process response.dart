/// 業務処理実行要求応答 共通モデル
/// 0x2181/0x2281/0x2381/0x2481/0x2581/0xB181
class ProcessResponse {
  final bool result;
  final int errCode;

  const ProcessResponse({
    required this.result,
    required this.errCode,
  });

  factory ProcessResponse.fromJson(Map<String, dynamic> json) {
    final common = json['COMMON'] as Map<String, dynamic>? ?? {};
    return ProcessResponse(
      result: common['RESULT'] as bool? ?? false,
      errCode: common['ERRCODE'] as int? ?? -1,
    );
  }

  @override
  String toString() =>
      'ProcessResponse(result: $result, errCode: $errCode)';
}
