import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memocrm/utils/refresh_repository.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final RefreshRepository refreshRepo;
  final Future<void> Function()? onRefreshFailed;
  Future<bool>? _refreshFuture;

  AuthInterceptor(this.dio, this.refreshRepo, {this.onRefreshFailed});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('login_accessToken');
    final tokenType = prefs.getString('login_tokenType') ?? 'Bearer';
    if (token != null) {
      options.headers['Authorization'] = '$tokenType $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final reqOptions = err.requestOptions;

    if (err.response?.statusCode == 401 &&
        reqOptions.extra['retried'] != true) {
      try {
        // 同時リフレッシュをまとめる（dio.lock は使わない）
        _refreshFuture ??= refreshRepo.refreshIfPossible();
        final didRefresh = await _refreshFuture;
        _refreshFuture = null;

        if (didRefresh != true) {
          await onRefreshFailed?.call();
          return handler.next(err);
        }

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('login_accessToken');
        final tokenType = prefs.getString('login_tokenType') ?? 'Bearer';
        if (token == null) return handler.next(err);

        final updatedHeaders = Map<String, dynamic>.from(reqOptions.headers);
        updatedHeaders['Authorization'] = '$tokenType $token';

        final options = Options(
          method: reqOptions.method,
          headers: updatedHeaders,
          responseType: reqOptions.responseType,
          contentType: reqOptions.contentType,
          followRedirects: reqOptions.followRedirects,
          validateStatus: reqOptions.validateStatus,
          extra: {...reqOptions.extra, 'retried': true},
        );

        final resp = await dio.request<dynamic>(
          reqOptions.path,
          data: reqOptions.data,
          queryParameters: reqOptions.queryParameters,
          options: options,
          cancelToken: reqOptions.cancelToken,
          onReceiveProgress: reqOptions.onReceiveProgress,
          onSendProgress: reqOptions.onSendProgress,
        );

        return handler.resolve(resp);
      } catch (_) {
        await onRefreshFailed?.call();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
