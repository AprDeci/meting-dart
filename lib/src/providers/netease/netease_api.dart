import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meting_dart/src/providers/netease/netease_crypto.dart';

class NeteaseApi {
  NeteaseApi({required this.dio, required this.headers});

  final Dio dio;
  final Map<String, dynamic> Function() headers;

  static const host = 'https://interface.music.163.com';

  Future<Map<String, dynamic>> eapiPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final url = '$host${eapiPath(normalizedPath)}';
    final encrypted = eapiEncrypt(normalizedPath, body);
    final response = await dio.post<Object?>(
      url,
      data: {'params': encrypted},
      options: Options(
        headers: headers(),
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

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
    throw FormatException('Unexpected Netease response: ${response.data}');
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
