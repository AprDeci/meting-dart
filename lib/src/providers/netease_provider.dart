import 'dart:convert';

import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/netease/netease_api.dart';
import 'package:meting_dart/src/providers/netease/netease_crypto.dart';
import 'package:meting_dart/src/providers/netease/netease_mapper.dart';

class NeteaseProvider extends BaseProvider {
  NeteaseProvider({required super.dio})
    : super(name: 'netease', header: _defaultHeader);

  late final NeteaseApi _api = NeteaseApi(
    dio: dio,
    headers: () => requestHeaders,
  );

  static const Map<String, dynamic> _defaultHeader = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0 Safari/537.36',
    'Referer': 'https://music.163.com/',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Cookie': 'os=pc; appver=8.9.70;',
  };

  @override
  Future<Object?> search(
    String keyword, {
    Map<String, dynamic> option = const {},
  }) async {
    final type = _intOption(option, 'type', 1);
    final page = _intOption(option, 'page', 1);
    final limit = _intOption(option, 'limit', 30);
    final response = await _api.eapiPost('/api/cloudsearch/pc', {
      's': keyword,
      'type': type,
      'limit': limit,
      'offset': (page - 1) * limit,
      'total': 'true',
    });
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(_pickList(response, ['result', 'songs']));
  }

  @override
  Future<Object?> song(String id) async {
    final response = await _api.eapiPost('/api/v3/song/detail', {
      'c': jsonEncode([
        {'id': _numOrString(id), 'v': 0},
      ]),
    });
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(_pickList(response, ['songs']));
  }

  @override
  Future<Object?> album(String id) async {
    final response = await _api.eapiPost('/api/v1/album/$id', {
      'total': 'true',
      'offset': '0',
      'id': id,
      'limit': '1000',
      'ext': 'true',
      'private_cloud': 'true',
    });
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(_pickList(response, ['songs']));
  }

  @override
  Future<Object?> artist(String id, {int limit = 50}) async {
    final response = await _api.eapiPost('/api/v1/artist/$id', {
      'ext': 'true',
      'private_cloud': 'true',
      'top': limit,
      'id': id,
    });
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(
      _pickList(response, ['songs']).isNotEmpty
          ? _pickList(response, ['songs'])
          : _pickList(response, ['hotSongs']),
    );
  }

  @override
  Future<Object?> playlist(String id) async {
    final response = await _api.eapiPost('/api/v6/playlist/detail', {
      's': '0',
      'id': id,
      'n': '1000',
      't': '0',
    });
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(_pickList(response, ['playlist', 'tracks']));
  }

  @override
  Future<Object?> url(String id, {int br = 320}) async {
    final response = await _api.eapiPost('/api/song/enhance/player/url', {
      'ids': [id],
      'br': br * 1000,
    });
    final urls = _pickList(response, ['data']);
    final mapped = urls.isEmpty ? <String, dynamic>{} : mapUrl(urls.first);
    if (!isFormat) {
      return mapped.isEmpty ? response : mapped;
    }
    return encodeMetingObject(mapped);
  }

  @override
  Future<Object?> lyric(String id) async {
    final response = await _newLyric(id);
    final mapped = mapLyric(response);
    if (!isFormat) {
      return mapped;
    }
    return encodeMetingObject(mapped);
  }

  Future<Map<String, dynamic>> _newLyric(String id) {
    return _api.eapiPost('/api/song/lyric/v1', {
      'id': id,
      'cp': false,
      'tv': 0,
      'lv': 0,
      'rv': 0,
      'kv': 0,
      'yv': 0,
      'ytv': 0,
      'yrv': 0,
    });
  }

  @override
  Future<String> pic(String id, {int size = 300}) async {
    final encryptedId = encryptCoverId(id);
    final url =
        'https://p3.music.126.net/$encryptedId/$id.jpg?param=${size}y$size';
    if (!isFormat) {
      return url;
    }
    return encodeMetingObject({'url': url, 'size': size});
  }

  int _intOption(Map<String, dynamic> option, String key, int defaultValue) {
    final value = option[key];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }

  Object _numOrString(String id) => int.tryParse(id) ?? id;

  List<dynamic> _pickList(Map<String, dynamic> data, List<String> path) {
    Object? value = data;
    for (final part in path) {
      if (value is Map) {
        value = value[part];
      } else {
        return const [];
      }
    }
    return value is List ? value : const [];
  }
}
