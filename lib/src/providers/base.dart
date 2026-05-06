import 'dart:convert';

import 'package:meting_dart/src/models/http_result.dart';
import 'package:meting_dart/src/models/provider_request.dart';

typedef RequestExecutor = Future<HttpResult> Function(ProviderRequest request);

abstract class BaseProvider {
  BaseProvider({this.name = 'base'});

  final String name;

  Map<String, dynamic> get header => {};

  ProviderRequest search(
    String keyword, {
    Map<String, dynamic> option = const {},
  });

  ProviderRequest song(String id);

  ProviderRequest album(String id);

  ProviderRequest artist(String id, {int limit = 50});

  ProviderRequest playlist(String id);

  ProviderRequest url(String id, {int br = 320});

  ProviderRequest lyric(String id);

  Future<String> pic(String id, {int size = 300});

  Map<String, dynamic> format(Map<String, dynamic> data);

  String urlDecode(String result) => result;

  String lyricDecode(String result) => result;

  Future<Object?> executeRequest(
    ProviderRequest request,
    RequestExecutor executor, {
    bool isFormat = false,
  }) async {
    var requestApi = request;

    if (requestApi.encode != null) {
      requestApi = await handleEncode(requestApi);
    }

    if (requestApi.method == HttpMethod.get && requestApi.body != null) {
      final params = Uri(
        queryParameters: _stringifyMap(requestApi.body!),
      ).query;
      final separator = requestApi.url.contains('?') ? '&' : '?';
      requestApi = ProviderRequest(
        url: '${requestApi.url}$separator$params',
        method: requestApi.method,
        body: null,
        encode: requestApi.encode,
        decode: requestApi.decode,
        format: requestApi.format,
        headerOnly: requestApi.headerOnly,
      );
    }

    final result = await executor(requestApi);

    if (!isFormat) {
      return result.raw;
    }

    Object? data = result.raw;

    if (requestApi.decode != null) {
      data = await handleDecode(requestApi.decode!, _rawToString(data));
    }

    if (requestApi.format != null) {
      data = cleanData(result, requestApi.format);
    }

    return data;
  }

  Future<ProviderRequest> handleEncode(ProviderRequest api) async => api;

  Future<String> handleDecode(DecodeType decodeType, String data) async {
    switch (decodeType) {
      case DecodeType.neteaseUrl:
      case DecodeType.kugouUrlNew:
      case DecodeType.kugouUrlLegacy:
        return urlDecode(data);
      case DecodeType.neteaseLyric:
      case DecodeType.kugouLyric:
        return lyricDecode(data);
    }
  }

  String cleanData(HttpResult result, String? rule) {
    Object? data;

    try {
      final raw = result.raw;
      data = raw is String ? jsonDecode(raw) : raw;
    } catch (_) {
      return jsonEncode([]);
    }

    if (rule != null && rule.isNotEmpty) {
      data = pickupData(data, rule);
    }

    if (data is Map<String, dynamic>) {
      data = [data];
    } else if (data is Map) {
      data = [Map<String, dynamic>.from(data)];
    }

    if (data is! List) {
      return jsonEncode([]);
    }

    final formatted = data.map((item) {
      if (item is Map<String, dynamic>) {
        return format(item);
      }
      if (item is Map) {
        return format(Map<String, dynamic>.from(item));
      }
      return item;
    }).toList();

    return jsonEncode(formatted);
  }

  Object pickupData(Object? array, String rule) {
    final parts = rule.split('.');
    Object? result = array;

    for (final part in parts) {
      if (result is Map && result.containsKey(part)) {
        result = result[part];
      } else {
        return <String, dynamic>{};
      }
    }

    return result ?? <String, dynamic>{};
  }

  Map<String, String> _stringifyMap(Object body) {
    if (body is Map) {
      return body.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return {};
  }

  String _rawToString(Object? raw) {
    if (raw is String) {
      return raw;
    }
    return jsonEncode(raw);
  }
}
