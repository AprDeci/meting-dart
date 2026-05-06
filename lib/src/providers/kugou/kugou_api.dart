import 'dart:convert';

import 'package:dio/dio.dart';

class KugouApi {
  KugouApi({required this.dio, required this.headers});

  final Dio dio;
  final Map<String, dynamic> Function() headers;

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final response = await dio.get<Object?>(
      url,
      queryParameters: query,
      options: Options(headers: headers(), responseType: ResponseType.plain),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final response = await dio.post<Object?>(
      url,
      data: body,
      options: Options(
        headers: headers(),
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(Response<Object?> response) {
    final statusCode = response.statusCode ?? 0;
    final data = _decode(response.data);
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException.badResponse(
        statusCode: statusCode,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw FormatException('Unexpected Kugou response: ${response.data}');
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
