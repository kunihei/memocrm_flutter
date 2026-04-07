import 'package:memocrm/utils/api/api_response.dart';

class LoginData {
  final int userCd;
  final String name;
  final String password;

  LoginData({required this.userCd, required this.name, required this.password});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      userCd: json['user_cd'],
      name: json['name'],
      password: json['password'],
    );
  }
}

class LoginResponse extends ApiResponse<LoginData> {
  const LoginResponse({
    required super.status,
    required super.messageList,
    super.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    final data = dataJson is Map<String, dynamic>
        ? LoginData.fromJson(dataJson)
        : null;

    return LoginResponse(
      status: json['status'],
      messageList: ApiResponse.parseMessage(json['message_list']),
      data: data,
    );
  }
}
