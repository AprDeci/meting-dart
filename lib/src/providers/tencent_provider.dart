import 'dart:convert';

import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/tencent/tencent_api.dart';
import 'package:meting_dart/src/providers/tencent/tencent_lyric_decoder.dart';
import 'package:meting_dart/src/providers/tencent/tencent_mapper.dart';
import 'package:meting_dart/src/providers/tencent/tencent_url_resolver.dart';

class TencentProvider extends BaseProvider {
  TencentProvider({required super.dio})
    : super(name: 'tencent', header: _defaultHeader);

  late final TencentApi _api = TencentApi(
    dio: dio,
    headers: () => requestHeaders,
  );
  late final TencentUrlResolver _urlResolver = TencentUrlResolver(
    api: _api,
    headers: () => requestHeaders,
  );

  static const Map<String, dynamic> _defaultHeader = {
    'Referer': 'http://y.qq.com',
    'Cookie':
        'pgv_pvi=22038528; pgv_si=s3156287488; '
        'pgv_pvid=5535248600; yplayer_open=1; '
        'ts_last=y.qq.com/portal/player.html; ts_uid=4847550686; '
        'yq_index=0; qqmusic_fromtag=66; player_exist=1',
    'User-Agent':
        'QQ%E9%9F%B3%E4%B9%90/54409 CFNetwork/901.1 Darwin/17.6.0 (x86_64)',
    'Accept': '*/*',
    'Accept-Language': 'zh-CN,zh;q=0.8,gl;q=0.6,zh-TW;q=0.4',
    'Connection': 'keep-alive',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  @override
  Future<Object?> search(
    String keyword, {
    Map<String, dynamic> option = const {},
  }) async {
    final page = _intOption(option, 'page', 1);
    final limit = _intOption(option, 'limit', 30);
    final response = await _api.get(
      'https://u.y.qq.com/cgi-bin/musicu.fcg',
      query: {
        'format': 'json',
        'data': jsonEncode({
          'comm': {'ct': '19', 'cv': '1859', 'uin': '0'},
          'req': {
            'method': 'DoSearchForQQMusicDesktop',
            'module': 'music.search.SearchCgiService',
            'param': {
              'grp': 1,
              'num_per_page': limit,
              'page_num': page,
              'query': keyword,
              'search_type': 0,
            },
          },
        }),
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(
      pickList(response, ['req', 'data', 'body', 'song', 'list']),
    );
  }

  @override
  Future<Object?> song(String id) async {
    final response = await _songRaw(id);
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(pickList(response, ['data']));
  }

  @override
  Future<Object?> album(String id) async {
    final response = await _api.get(
      'https://c.y.qq.com/v8/fcg-bin/fcg_v8_album_detail_cp.fcg',
      query: {
        'albummid': id,
        'platform': 'mac',
        'format': 'json',
        'newsong': 1,
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(pickList(response, ['data', 'getSongInfo']));
  }

  @override
  Future<Object?> artist(String id, {int limit = 50}) async {
    final response = await _api.get(
      'https://c.y.qq.com/v8/fcg-bin/fcg_v8_singer_track_cp.fcg',
      query: {
        'singermid': id,
        'begin': 0,
        'num': limit,
        'order': 'listen',
        'platform': 'mac',
        'newsong': 1,
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(pickList(response, ['data', 'list']));
  }

  @override
  Future<Object?> playlist(String id) async {
    final response = await _api.get(
      'https://c.y.qq.com/v8/fcg-bin/fcg_v8_playlist_cp.fcg',
      query: {
        'id': id,
        'format': 'json',
        'newsong': 1,
        'platform': 'jqspaframe.json',
      },
    );
    if (!isFormat) {
      return response;
    }
    return encodeMetingList(
      pickList(response, ['data', 'cdlist', 0, 'songlist']),
    );
  }

  @override
  Future<Object?> url(String id, {int br = 320}) async {
    final response = await _songRaw(id);
    final mapped = await _urlResolver.resolve(response, br: br);
    if (!isFormat) {
      return mapped;
    }
    return encodeMetingObject(mapped);
  }

  @override
  Future<Object?> lyric(String id) async {
    final response = await _api.getPlain(
      'https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg',
      query: {'songmid': id, 'g_tk': '5381'},
    );
    final decoded = decodeTencentLyric(response);
    final mapped = mapLyric(
      decoded['lyric'] ?? '',
      tlyric: decoded['tlyric'] ?? '',
    );
    if (!isFormat) {
      return mapped;
    }
    return encodeMetingObject(mapped);
  }

  @override
  Future<String> pic(String id, {int size = 300}) async {
    final url =
        'https://y.gtimg.cn/music/photo_new/T002R${size}x${size}M000$id.jpg?max_age=2592000';
    if (!isFormat) {
      return url;
    }
    return encodeMetingObject({'url': url});
  }

  Future<Map<String, dynamic>> _songRaw(String id) {
    return _api.get(
      'https://c.y.qq.com/v8/fcg-bin/fcg_play_single_song.fcg',
      query: {'songmid': id, 'platform': 'yqq', 'format': 'json'},
    );
  }

  int _intOption(Map<String, dynamic> option, String key, int defaultValue) {
    final value = option[key];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}
