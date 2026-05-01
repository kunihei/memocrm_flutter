import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/login/view_model/login_viewmodel.dart';
import 'package:memocrm/utils/refresh_repository.dart';
import 'package:memocrm/utils/auth_interceptor.dart';

/// Riverpod の `Provider`を使用して、アプリ全体で使い回す `Dio` クライアントを生成する
///
/// 要点:
/// - 環境変数 `API_BASE_URL` からベース URL を取得します（未設定時はローカル開発用のデフォルトを利用）。
/// - `BaseOptions` で接続/受信タイムアウトや `contentType` を設定します。
/// - デバッグ（assert が有効）時のみ `LogInterceptor` を追加してリクエスト/レスポンスのボディをログ出力します。
final dioProvider = Provider<Dio>((ref) {
  // 環境変数から API のベース URL を読み取る。CI/本番ではビルド時に `--dart-define` 等で上書き可能。
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081/api/',
  );

  // 共通の設定をまとめたオプション。
  // - baseUrl: リクエスト時に相対パスで記述できるようにする
  // - connect/receive タイムアウト: ネットワーク待ちを短めに設定
  // - contentType: フォームエンコードを使用する API に合わせて設定
  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: Headers.formUrlEncodedContentType,
  );

  // Dio インスタンスを生成
  final dio = Dio(options);

  // デバッグ時のみ詳細ログを出すため `assert` 内でインターセプタを追加。
  // assertは「即時実行クロージャー」開発でしか実行されないため、本番環境でのログ漏れを防げます。
  // assert 内のコードはリリースビルドでは実行されないため、本番環境でのログ漏れを防げます。
  // LogInterceptorはHTTP リクエスト／レスポンス／エラーの内容をログをデバッグコンソールに出力する役割
  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true, // リクエストのボディをログ出力（開発時のみ）
        responseBody: true, // レスポンスのボディをログ出力（開発時のみ）
        requestHeader: false, // ヘッダは冗長になりがちなので無効
        responseHeader: false,
      ),
    );
    return true;
  }());

  return dio;
});

final refreshRepositoryProvider = Provider<RefreshRepository>((ref) {
  final dio = ref.read(dioProvider);
  return RefreshRepository(dio);
});

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final dio = ref.read(dioProvider);
  final repo = ref.read(refreshRepositoryProvider);
  final interceptor = AuthInterceptor(dio, repo, onRefreshFailed: () async {
    ref.read(loginViewModelProvider.notifier).logout();
  },);
  dio.interceptors.add(interceptor);
  return interceptor;
});
