import 'package:memocrm/utils/api/api_response.dart';

class LoginData {
  // final int userCd;
  // final String name;
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String tokenType;

  LoginData({
    // required this.userCd,
    // required this.name,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.tokenType,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      // userCd: json['user_cd'],
      // name: json['name'],
      accessToken: json['access_token'],
      accessTokenExpiresAt: DateTime.parse(json['access_token_expires_at']),
      refreshToken: json['refresh_token'],
      refreshTokenExpiresAt: DateTime.parse(json['refresh_token_expires_at']),
      tokenType: json['token_type'],
    );
  }
}

class LoginResponse extends ApiResponse<LoginData> {
  const LoginResponse({
    required super.status,
    required super.messageList,
    super.data,
  });

  factory LoginResponse.fromJson(
    Map<String, dynamic> json, {
    required int status,
  }) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    return LoginResponse(
      status: status,
      messageList: ApiResponse.parseMessage(json['message_list']),
      data: dataJson != null ? LoginData.fromJson(dataJson) : null,
    );
  }
}
