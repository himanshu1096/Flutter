/// ログイン要求応答 (0xA181) のデータモデル
class LoginResponse {
  final bool result;
  final int errCode;
  final int authority;

  const LoginResponse({
    required this.result,
    required this.errCode,
    required this.authority,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final common = json['COMMON'] as Map<String, dynamic>? ?? {};
    final data = json['DATA'] as Map<String, dynamic>? ?? {};
    return LoginResponse(
      result: common['RESULT'] as bool? ?? false,
      errCode: common['ERRCODE'] as int? ?? -1,
      authority: data['AUTHORITY'] as int? ?? 0,
    );
  }

  /// 認証失敗
  bool get isAuthFailure => authority == 0;

  /// 通常ユーザー → Dartアプリ継続
  bool get isNormalUser => authority == 1;

  /// メンテナンスユーザー → 別アプリへ
  bool get isMaintenanceUser => authority == 99;
}
