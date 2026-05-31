import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/memos/models/memo_model.dart';
import 'package:memocrm/utils/api/api_path.dart';
import 'package:memocrm/utils/dio_client.dart';

class MemoRepo {

  MemoRepo(this._dio);
  final Dio _dio;

  Future<MemoResponse> fetchMemoList(int coCd) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiParentPath.memos}/${ApiPath.list}/$coCd',
    );

    final responseBody = response.data ?? const <String, dynamic>{};
    return MemoResponse.fromJson(responseBody, status: response.statusCode ?? 0);
  }
}

final memoRepoProvider = Provider<MemoRepo>((ref) {
  ref.watch(authInterceptorProvider);
  final dio = ref.watch(dioProvider);

  return MemoRepo(dio);
});