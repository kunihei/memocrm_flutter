import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/company/models/co_models.dart';
import 'package:memocrm/utils/api/api_path.dart';
import 'package:memocrm/utils/dio_client.dart';


class CoRepo {
  CoRepo(this._dio);
  final Dio _dio;

  Future<CoResponse> fetchCoList() async {
    final response = await _dio.get<Map<String, dynamic>>('${ApiParentPath.customers}/${ApiPath.coList}');
    final responseBody = response.data ?? const <String, dynamic>{};
    return CoResponse.fromJson(responseBody, status: response.statusCode ?? 0);
  }
}

final coRepoProvider = Provider<CoRepo>((ref) {
  // これを読むことで Dio に AuthInterceptor が登録される
  ref.watch(authInterceptorProvider);
  final dio = ref.watch(dioProvider);
  return CoRepo(dio);
});