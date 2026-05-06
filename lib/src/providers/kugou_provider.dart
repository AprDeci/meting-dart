import 'dart:convert';

import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/kugou/kugou_api.dart';
import 'package:meting_dart/src/providers/kugou/kugou_mapper.dart';

class KugouProvider extends BaseProvider {
  KugouProvider({required super.dio})
    : super(name: 'kugou', header: _defaultHeader);

  late final KugouApi _api = KugouApi(dio: dio, headers: () => requestHeaders);

  static const Map<String, dynamic> _defaultHeader = {
    'User-Agent': 'IPhone-8990-searchSong',
    'UNI-UserAgent': 'iOS11.4-Phone8990-1009-0-WiFi',
  };

  @override
  Future<Object?> search(
    String keyword, {
    Map<String, dynamic> option = const {},
  }) async {
    final page = _intOption(option, 'page', 1);
    final limit = _intOption(option, 'limit', 30);
    final response = await _api.get(
      'http://mobilecdn.kugou.com/api/v3/search/song',
      query: {
        'api_ver': 1,
        'area_code': 1,
        'correct': 1,
        'pagesize': limit,
        'plat': 2,
        'tag': 1,
        'sver': 5,
        'showtype': 10,
        'page': page,
        'keyword': keyword,
        'version': 8990,
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(pickList(response, ['data', 'info']));
  }

  @override
  Future<Object?> song(String id) async {
    final response = await _songRaw(id);
    if (!isFormat) {
      return response;
    }
    return encodeMetingList([response]);
  }

  @override
  Future<Object?> album(String id) async {
    final response = await _api.get(
      'http://mobilecdn.kugou.com/api/v3/album/song',
      query: {
        'albumid': id,
        'area_code': 1,
        'plat': 2,
        'page': 1,
        'pagesize': -1,
        'version': 8990,
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(pickList(response, ['data', 'info']));
  }

  @override
  Future<Object?> artist(String id, {int limit = 50}) async {
    final response = await _api.get(
      'http://mobilecdn.kugou.com/api/v3/singer/song',
      query: {
        'singerid': id,
        'area_code': 1,
        'page': 1,
        'plat': 0,
        'pagesize': limit,
        'version': 8990,
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(pickList(response, ['data', 'info']));
  }

  @override
  Future<Object?> playlist(String id) async {
    final response = await _api.get(
      'http://mobilecdn.kugou.com/api/v3/special/song',
      query: {
        'specialid': id,
        'area_code': 1,
        'page': 1,
        'plat': 2,
        'pagesize': -1,
        'version': 8990,
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(pickList(response, ['data', 'info']));
  }

  @override
  Future<Object?> url(String id, {int br = 320}) {
    throw UnimplementedError('Kugou url is not implemented yet');
  }

  @override
  Future<Object?> lyric(String id) async {
    final search = await _api.get(
      'http://krcs.kugou.com/search',
      query: {
        'keyword': ' - ',
        'ver': 1,
        'hash': id,
        'client': 'mobi',
        'man': 'yes',
      },
    );
    final candidates = pickList(search, ['candidates']);
    if (candidates.isEmpty) {
      return _lyricResult('');
    }
    final first = asMap(candidates.first);
    final accessKey = first['accesskey']?.toString() ?? '';
    final lyricId = first['id']?.toString() ?? '';
    if (accessKey.isEmpty || lyricId.isEmpty) {
      return _lyricResult('');
    }

    final download = await _api.get(
      'http://lyrics.kugou.com/download',
      query: {
        'charset': 'utf8',
        'accesskey': accessKey,
        'id': lyricId,
        'client': 'mobi',
        'fmt': 'lrc',
        'ver': 1,
      },
    );
    final content = download['content']?.toString() ?? '';
    if (content.isEmpty) {
      return _lyricResult('');
    }
    final lyric = utf8.decode(base64Decode(content));
    return _lyricResult(lyric);
  }

  @override
  Future<String> pic(String id, {int size = 300}) async {
    final song = await _songRaw(id);
    final rawUrl = song['imgUrl']?.toString() ?? '';
    final url = rawUrl.isEmpty
        ? ''
        : rawUrl.replaceAll('{size}', size.toString());
    if (!isFormat) {
      return url;
    }
    return encodeMetingObject({'url': url, 'size': size});
  }

  Future<Map<String, dynamic>> _songRaw(String id) {
    return _api.post(
      'http://m.kugou.com/app/i/getSongInfo.php',
      body: {'cmd': 'playInfo', 'hash': id, 'from': 'mkugou'},
    );
  }

  Object _lyricResult(String lyric) {
    final mapped = mapLyric(lyric);
    if (!isFormat) {
      return mapped;
    }
    return encodeMetingObject(mapped);
  }

  int _intOption(Map<String, dynamic> option, String key, int defaultValue) {
    final value = option[key];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}
