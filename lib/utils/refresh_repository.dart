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

  // インターセプタなしの Dio を作る（refresh 呼び出し用）
  Dio _createAuthlessDio() {
    return Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        contentType: dio.options.contentType,
      ),
    );
  }

  /// refresh token を使ってトークン更新を試みる
  /// 成功したら SharedPreferences に新しいトークンを保存して true を返す
  Future<bool> refreshIfPossible() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_prefRefreshToken);
    if (refreshToken == null) return false;

    try {
      final client = _createAuthlessDio();
      final resp = await client.post(
        'refresh',
        data: {'refresh_token': refreshToken},
      );

      final Map<String, dynamic> body =
          (resp.data is Map && resp.data['data'] is Map)
          ? resp.data['data'] as Map<String, dynamic>
          : resp.data as Map<String, dynamic>;

      final accessToken = body['access_token'] as String?;
      final accessTokenExpiresAt = body['access_token_expires_at'] as String?;
      final newRefreshToken = body['refresh_token'] as String?;
      final refreshTokenExpiresAt = body['refresh_token_expires_at'] as String?;
      final tokenType = body['token_type'] as String?;

      if (accessToken == null || newRefreshToken == null) return false;

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
    } catch (_) {
      return false;
    }
  }
}
