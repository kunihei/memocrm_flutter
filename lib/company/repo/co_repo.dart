import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/company/models/co_models.dart';
import 'package:memocrm/utils/api/api_path.dart';
import 'package:memocrm/utils/dio_client.dart';

/// 企業情報を取得するための Repository。
///
/// 目的:
/// - 企業一覧画面や ViewModel から、企業一覧 API の呼び出し処理を直接扱わずに済むようにする。
/// - Dio を使った HTTP 通信、API パスの組み立て、レスポンス JSON からモデルへの変換をこの層に集約する。
///
/// 概要:
/// - [CoRepo] は Dio インスタンスを受け取り、その Dio を使って企業一覧 API にアクセスする。
/// - API のレスポンス本文は [CoResponse.fromJson] に渡して、画面側で扱いやすいモデルへ変換する。
/// - HTTP ステータスコードもモデルへ渡すことで、呼び出し元が成功/失敗などの状態を判断できるようにしている。
///
/// 注意:
/// - 認証ヘッダーなどの共通処理は Dio 側の Interceptor に任せる。
/// - この Repository では、取得したデータを加工しすぎず、API レスポンスをモデルへ変換する責務に留める。
class CoRepo {
  /// 外部から Dio を注入して Repository を作成する。
  ///
  /// Dio をコンストラクタで受け取ることで、テスト時にはモック Dio を渡せる。
  /// また、アプリ本体では Riverpod Provider 経由で共通設定済みの Dio を利用できる。
  CoRepo(this._dio);

  /// API 通信に使う Dio クライアント。
  ///
  /// `dioProvider` で生成された Dio が渡される想定。
  /// 認証やログ出力などの共通処理は、Dio に登録された Interceptor 側で実行される。
  final Dio _dio;

  /// 企業一覧を API から取得する。
  ///
  /// 処理の流れ:
  /// 1. `ApiParentPath.customers` と `ApiPath.coList` を連結して、企業一覧 API の URL パスを作る。
  /// 2. Dio の GET リクエストを実行し、JSON オブジェクト形式のレスポンスを受け取る。
  /// 3. `response.data` が null の場合でも後続処理が落ちないように、空の Map を代替値として使う。
  /// 4. レスポンス本文と HTTP ステータスコードを [CoResponse.fromJson] に渡して、[CoResponse] に変換する。
  ///
  /// 戻り値:
  /// - API レスポンスをもとに生成した [CoResponse]。
  ///
  /// 例外:
  /// - 通信エラーやサーバーエラーなどは Dio から例外として投げられる。
  /// - このメソッド内では catch せず、呼び出し元の ViewModel などでエラーハンドリングする前提。
  Future<CoResponse> fetchCoList() async {
    // 企業一覧 API のエンドポイントへ GET リクエストを送る。
    // `get<Map<String, dynamic>>` と型を指定することで、レスポンス本文を JSON オブジェクトとして扱う。
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiParentPath.customers}/${ApiPath.coList}',
    );

    // API のレスポンス本文を取り出す。
    // Dio の `response.data` は null になる可能性があるため、null の場合は空の Map にして
    // `CoResponse.fromJson` 側へ常に Map を渡せるようにしている。
    final responseBody = response.data ?? const <String, dynamic>{};

    // JSON 本文と HTTP ステータスコードを CoResponse に変換する。
    // `statusCode` が null のケースにも備え、取得できなかった場合は 0 を渡す。
    return CoResponse.fromJson(responseBody, status: response.statusCode ?? 0);
  }
}

/// [CoRepo] をアプリ内で利用するための Riverpod Provider。
///
/// ViewModel や画面側では、この Provider を `ref.watch` / `ref.read` することで
/// 企業一覧取得用の Repository を取得できる。
final coRepoProvider = Provider<CoRepo>((ref) {
  // これを読むことで Dio に AuthInterceptor が登録される。
  // AuthInterceptor は認証トークン付与など、API 通信前後の共通処理を担当する。
  ref.watch(authInterceptorProvider);

  // 共通設定済みの Dio インスタンスを取得する。
  // baseUrl、タイムアウト、Interceptor などの設定は dioProvider 側に集約されている想定。
  final dio = ref.watch(dioProvider);

  // Dio を注入して CoRepo を生成する。
  // これにより、CoRepo 自体は Dio の作り方を知らず、企業 API の呼び出しだけに集中できる。
  return CoRepo(dio);
});
