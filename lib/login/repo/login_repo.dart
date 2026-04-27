import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/login/models/login_models.dart';
import 'package:memocrm/utils/api/api_path.dart';
import 'package:memocrm/utils/dio_client.dart';

/// - API を呼び出す責務を持つ処理ロジック
/// - ネットワークリクエスト自体はここで行い、レスポンスの JSON を LoginResponse に変換して返す。
/// - エラー（ネットワークエラーやサーバエラー）はこのメソッド内で捕捉せずに呼び出し元へ伝播させる設計になっているため、
///   呼び出し側で適切にハンドリングしてください（例: try/catch）。
class LoginRepo {
  LoginRepo(this._dio);

  // 注入された Dio クライアント。DI によりテスト時はモックを渡すことができる
  final Dio _dio;

  /// loginのAPIを呼び出しメソッド
  /// - userCd / password を受け取り、サーバのログインエンドポイントを POST で呼ぶ。
  /// - JSON を LoginResponse.fromJson に渡して変換したオブジェクトを返却する。
  /// - 戻り値は成功時の LoginResponse 失敗時は例外がそのまま投げられる。
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    // POST リクエストでログインAPI を叩く
    // - API側が期待するパラメータ名に合わせてキーはスネークケースで送る
    // - ジェネリクスを指定して response.data が Map<String, dynamic> として扱えるようにする
    final response = await _dio.post<Map<String, dynamic>>(
      ApiPath.login,
      data: {'email': email, 'password': password},
      options: Options(extra: {'skipAuth': true}),
    );

    // サーバが空レスポンスを返した場合に備えてデフォルト空の Map を用意
    final responseBody = response.data ?? const <String, dynamic>{};
    // JSON → LoginResponse へ変換して返却
    return LoginResponse.fromJson(responseBody, status: response.statusCode ?? 0);
  }
}

/// - Riverpod の Providerを使用し LoginRepo のインスタンスを生成する。
/// - UI 層やユースケース層はこの Provider を通じてリポジトリを取得する。
final loginRepositoryProvider = Provider<LoginRepo>((ref) {
  final dio = ref.watch(dioProvider);
  return LoginRepo(dio);
});
