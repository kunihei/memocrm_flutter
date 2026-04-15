import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefreshRepository {
  final Dio dio;
  RefreshRepository(this.dio);

  static const _prefAccessToken = 'login_accessToken';
  static const _prefAccessTokenExpiresAt = 'login_accessTokenExpiresAt';
  static const _prefRefreshToken = 'login_refreshToken';
  static const _prefRefreshTokenExpiresAt = 'login_refreshTokenExpiresAt';
  static const _prefTokenType = 'login_tokenType';

  /// refresh tokenを使ってトークン更新を試みる
  /// 成功したら sharedPreferences に新しいトークンを保存して true を返す
  Future<bool> refreshIfPossible() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_prefRefreshToken);
    if (refreshToken == null) {
      return false;
    }

    try {
      final response = await dio.post(
        'refresh',
        data: {'refresh_token': refreshToken},
      );

      final Map<String, dynamic> body =
          (response.data is Map && response.data['data'] is Map)
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      final accessToken = body['access_token'];
      final accessTokenExpiresAt = body['access_token_expires_at'];
      final newRefreshToken = body['refresh_token'];
      final refreshTokenExpiresAt = body['refresh_token_expires_at'];
      final tokenType = body['token_type'];

      await prefs.setString(_prefAccessToken, accessToken);
      if (accessTokenExpiresAt != null) {
        await prefs.setString(_prefAccessTokenExpiresAt, accessTokenExpiresAt);
      }
      await prefs.setString(_prefRefreshToken, newRefreshToken);
      if (refreshTokenExpiresAt != null) {
        await prefs.setString(
          _prefRefreshTokenExpiresAt,
          refreshTokenExpiresAt,
        );
      }
      if (tokenType != null) {
        await prefs.setString(_prefTokenType, tokenType);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
