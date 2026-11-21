import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../end_points.dart';
import 'dio_interceptors.dart';

class DioHelper {
  static Dio? dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: BASE_URL,
        followRedirects: false,
        receiveDataWhenStatusError: true,
        // Only 2xx is a success. The original accepted everything below 500,
        // so a 401 or a 403 arrived as an ordinary response and every
        // repository had to hand-check the status — several of them missed
        // cases. Non-2xx now raises and ErrorInterceptor classifies it once.
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    /// DIO [HEADERS]
    dio!.options.headers = {'Content-Type': 'application/json'};

    /// DIO [INTERCEPTORS]
    ///
    /// Order matters, and it is not the obvious one. Dio runs `onError` in the
    /// order the interceptors were added, and [ErrorInterceptor] ends with
    /// `handler.reject`, which **terminates the chain** — so a logger placed
    /// after it never sees a single failed response. The logger sits in the
    /// middle instead: after [AppInterceptors], so the request it prints
    /// already carries the token and `Accept-Language`, and before
    /// [ErrorInterceptor], so it still prints the response or error that
    /// interceptor is about to swallow.
    dio!.interceptors.addAll({
      AppInterceptors(dio!),
      if (kDebugMode)
        PrettyDioLogger(
          error: true,
          request: true,
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      ErrorInterceptor(),
    });
  }

  /// METHOD [POST] DATA FROM API
  static Future<Response> post({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    data,
  }) async {
    dio!.options.headers = headers ?? {'Content-Type': 'application/json'};
    return await dio!.post(url, data: data, queryParameters: query);
  }

  /// METHOD [GET] DATA FROM API
  static Future<Response> get({
    required String url,
    Map<String, dynamic>? query,
    data,
  }) async {
    return await dio!.get(url, queryParameters: query, data: data);
  }

  /// METHOD [DELETE] DATA FROM API
  static Future<Response> delete({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    dynamic data,
  }) async {
    dio!.options.headers = headers ?? {'Content-Type': 'application/json'};
    return await dio!.delete(url, data: data, queryParameters: query);
  }

  /// METHOD [PATCH] UPDATE DATA ON API
  static Future<Response> patch({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    dynamic data,
  }) async {
    dio!.options.headers = headers ?? {'Content-Type': 'application/json'};
    return await dio!.patch(url, data: data, queryParameters: query);
  }

  /// METHOD [PUT] UPDATE DATA ON API
  static Future<Response> put({
    required String url,
    Map<String, dynamic>? query,
    dynamic data,
  }) async {
    return await dio!.put(url, data: data, queryParameters: query);
  }

  /// METHOD [DOWNLOAD] FILE FROM API
  static Future<void> download({
    required String url,
    required String savePath,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      dio!.options.headers = headers ?? {'Content-Type': 'application/json'};
      await dio!.download(url, savePath, onReceiveProgress: onReceiveProgress);
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }
}
