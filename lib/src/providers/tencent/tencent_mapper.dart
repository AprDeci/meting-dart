import 'dart:convert';

Map<String, dynamic> mapSong(dynamic song) {
  final data = _unwrapMusicData(asMap(song));
  final album = asMap(data['album']);
  final id = (data['mid'] ?? data['songmid'])?.toString() ?? '';
  final albumMid = (album['mid'] ?? data['albummid'])?.toString() ?? '';

  return {
    'id': id,
    'name': (data['name'] ?? data['songname'])?.toString() ?? '',
    'artist': _artists(data),
    'album': (album['title'] ?? album['name'] ?? data['albumname'])
            ?.toString()
            .trim() ??
        '',
    'duration': _duration(data),
    'pic_id': albumMid,
    'url_id': id,
    'lyric_id': id,
    'source': 'tencent',
  };
}

Map<String, dynamic> mapUrl({
  required String url,
  required int size,
  required int br,
}) => {
  'url': url,
  'size': size,
  'br': br,
};

Map<String, dynamic> mapLyric(String lyric, {String tlyric = ''}) => {
  'lyric': lyric,
  'tlyric': tlyric,
};

String encodeMetingList(Iterable<dynamic> songs) {
  return jsonEncode(songs.map(mapSong).toList());
}

String encodeMetingObject(Map<String, dynamic> data) => jsonEncode(data);

List<dynamic> pickList(Map<String, dynamic> data, List<Object> path) {
  Object? value = data;
  for (final part in path) {
    if (value is Map) {
      value = value[part];
    } else if (value is List && part is int && part >= 0 && part < value.length) {
      value = value[part];
    } else {
      return const [];
    }
  }
  return value is List ? value : const [];
}

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _unwrapMusicData(Map<String, dynamic> data) {
  final musicData = data['musicData'];
  return musicData == null ? data : asMap(musicData);
}

List<String> _artists(Map<String, dynamic> data) {
  final singers = data['singer'];
  if (singers is List) {
    return singers
        .map((singer) => asMap(singer)['name'])
        .whereType<Object>()
        .map((name) => name.toString())
        .where((name) => name.isNotEmpty)
        .toList();
  }
  final singer = (data['singername'] ?? data['singer'])?.toString() ?? '';
  if (singer.isEmpty) {
    return const [];
  }
  return singer
      .split(RegExp(r'、|/|&'))
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList();
}

int _duration(Map<String, dynamic> data) {
  final interval = data['interval'];
  if (interval is num) {
    return (interval * 1000).round();
  }
  return (num.tryParse(interval?.toString() ?? '') ?? 0) * 1000 ~/ 1;
}
