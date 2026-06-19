/// QRサーバ照会要求応答 (0x1181) データモデル
class QrServerResponse {
  final bool result;
  final int errCode;

  const QrServerResponse({
    required this.result,
    required this.errCode,
  });

  factory QrServerResponse.fromJson(Map<String, dynamic> json) {
    final common = json['COMMON'] as Map<String, dynamic>? ?? {};
    return QrServerResponse(
      result: common['RESULT'] as bool? ?? false,
      errCode: common['ERRCODE'] as int? ?? -1,
    );
  }

  @override
  String toString() =>
      'QrServerResponse(result: $result, errCode: $errCode)';
}
