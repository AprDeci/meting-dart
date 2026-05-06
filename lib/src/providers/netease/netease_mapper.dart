import 'dart:convert';

Map<String, dynamic> mapSong(dynamic song) {
  final data = _asMap(song);
  final album = _asMap(data['al'] ?? data['album']);
  final artists = _asList(data['ar'] ?? data['artists']);
  final artistNames = artists
      .map((artist) => _asMap(artist)['name'])
      .whereType<Object>()
      .map((name) => name.toString())
      .toList();

  var picId =
      (album['pic_str'] ?? album['pic'] ?? album['picId'])?.toString() ?? '';
  final picUrl = album['picUrl']?.toString();
  final picUrlMatch = picUrl == null
      ? null
      : RegExp(r'/(\d+)\.').firstMatch(picUrl);
  if (picUrlMatch != null) {
    picId = picUrlMatch.group(1) ?? picId;
  }

  return {
    'id': data['id']?.toString() ?? '',
    'name': data['name']?.toString() ?? '',
    'artist': artistNames,
    'album': album['name']?.toString() ?? '',
    'pic_id': picId,
    'url_id': data['id']?.toString() ?? '',
    'lyric_id': data['id']?.toString() ?? '',
    'source': 'netease',
  };
}

Map<String, dynamic> mapUrl(dynamic item) {
  final data = _asMap(item);
  final uf = _asMap(data['uf']);
  final playUrl = data['url'] ?? uf['url'];
  final br = data['br'];
  return {
    'url': playUrl?.toString() ?? '',
    'size': data['size'],
    'br': br is num ? br ~/ 1000 : int.tryParse(br?.toString() ?? '') ?? br,
  };
}

Map<String, dynamic> mapLyric(Map<String, dynamic> data) {
  return {
    'lyric': _asMap(data['lrc'])['lyric']?.toString() ?? '',
    'tlyric': _asMap(data['tlyric'])['lyric']?.toString() ?? '',
  };
}

String encodeMetingList(Iterable<dynamic> songs) {
  return jsonEncode(songs.map(mapSong).toList());
}

String encodeMetingObject(Map<String, dynamic> data) => jsonEncode(data);

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];
