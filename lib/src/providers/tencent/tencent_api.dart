import 'dart:convert';

import 'package:dio/dio.dart';

class TencentApi {
  TencentApi({required this.dio, required this.headers});

  final Dio dio;
  final Map<String, dynamic> Function() headers;

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _get(url, query: query);
    final data = _decode(response.data);
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw FormatException('Unexpected Tencent response: ${response.data}');
  }

  Future<String> getPlain(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _get(url, query: query);
    return response.data?.toString() ?? '';
  }

  Future<Response<Object?>> _get(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final response = await dio.get<Object?>(
      url,
      queryParameters: query,
      options: Options(headers: headers(), responseType: ResponseType.plain),
    );
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException.badResponse(
        statusCode: statusCode,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    return response;
  }

  Object? _decode(Object? data) {
    if (data is String) {
      if (data.isEmpty) {
        return <String, dynamic>{};
      }
      return jsonDecode(data);
    }
    return data;
  }
}
