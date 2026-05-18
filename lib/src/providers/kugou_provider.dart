import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/kugou/kugou_api.dart';
import 'package:meting_dart/src/providers/kugou/kugou_lyric_decoder.dart';
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
    final candidate = asMap(candidates.first);
    final accessKey = candidate['accesskey']?.toString() ?? '';
    final lyricId = candidate['id']?.toString() ?? '';

    if (accessKey.isEmpty || lyricId.isEmpty) {
      return _lyricResult('');
    }

    final lrcDownload = await _downloadLyric(
      accessKey: accessKey,
      lyricId: lyricId,
      fmt: 'lrc',
    );
    final lyric = _decodeDownload(lrcDownload, fmt: 'lrc');
    if (lyric.isEmpty) {
      return _lyricResult('');
    }

    final klyric = await _downloadKrc(accessKey: accessKey, lyricId: lyricId);
    return _lyricResult(lyric, klyric: klyric);
  }

  @override
  Future<String> pic(String id, {int size = 300}) async {
    final song = await _songRaw(id);
    final rawUrl = pickPicUrl(song);
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

  Future<Map<String, dynamic>> _downloadLyric({
    required String accessKey,
    required String lyricId,
    required String fmt,
  }) {
    return _api.get(
      'http://lyrics.kugou.com/download',
      query: {
        'charset': 'utf8',
        'accesskey': accessKey,
        'id': lyricId,
        'client': 'android',
        'fmt': fmt,
        'ver': 1,
      },
    );
  }

  Future<String> _downloadKrc({
    required String accessKey,
    required String lyricId,
  }) async {
    try {
      final download = await _downloadLyric(
        accessKey: accessKey,
        lyricId: lyricId,
        fmt: 'krc',
      );
      return _decodeDownload(download, fmt: 'krc');
    } catch (_) {
      return '';
    }
  }

  String _decodeDownload(Map<String, dynamic> download, {required String fmt}) {
    final content = download['content']?.toString() ?? '';
    if (content.isEmpty) {
      return '';
    }

    try {
      final contentType = int.tryParse(
        download['contenttype']?.toString() ?? '',
      );
      if (fmt == 'lrc' || contentType != 0) {
        return decodeLrcContent(content);
      }
      return decodeKrcContent(content);
    } catch (_) {
      return '';
    }
  }

  Object _lyricResult(String lyric, {String klyric = ''}) {
    final mapped = mapLyric(lyric, klyric: klyric);
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
