import 'dart:convert';

Map<String, dynamic> mapSong(dynamic song) {
  final data = asMap(song);
  final filename = (data['filename'] ?? data['fileName'])?.toString();
  final parsed = _parseFilename(filename);
  final artists = _artists(data, parsed.artist);

  return {
    'id': (data['hash'] ?? data['audio_id'] ?? data['id'])?.toString() ?? '',
    'name':
        (data['songName'] ?? data['songname'] ?? data['song_name'])
            ?.toString() ??
        parsed.name,
    'artist': artists,
    'album': (data['album_name'] ?? data['albumName'])?.toString() ?? '',
    'pic_id': (data['imgUrl'] ?? data['image'])?.toString() ?? '',
    'url_id': (data['hash'] ?? data['encode_album_audio_id'])?.toString() ?? '',
    'lyric_id':
        (data['hash'] ?? data['encode_album_audio_id'])?.toString() ?? '',
    'source': 'kugou',
  };
}

Map<String, dynamic> mapLyric(String lyric) => {'lyric': lyric, 'tlyric': ''};

String encodeMetingList(Iterable<dynamic> songs) {
  return jsonEncode(songs.map(mapSong).toList());
}

String encodeMetingObject(Map<String, dynamic> data) => jsonEncode(data);

List<dynamic> pickList(Map<String, dynamic> data, List<String> path) {
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

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<String> _artists(Map<String, dynamic> data, String fallback) {
  final authors = data['authors'];
  if (authors is List) {
    final names = authors
        .map((author) => asMap(author)['author_name'] ?? asMap(author)['name'])
        .whereType<Object>()
        .map((name) => name.toString())
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isNotEmpty) {
      return names;
    }
  }

  final singer =
      (data['singername'] ?? data['singerName'] ?? data['author_name'])
          ?.toString();
  final raw = singer == null || singer.isEmpty ? fallback : singer;
  if (raw.isEmpty) {
    return const [];
  }
  return raw
      .split(RegExp(r'、|/|&'))
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList();
}

({String artist, String name}) _parseFilename(String? filename) {
  if (filename == null || filename.isEmpty) {
    return (artist: '', name: '');
  }
  final parts = filename.split(' - ');
  if (parts.length < 2) {
    return (artist: '', name: filename);
  }
  return (
    artist: parts.first.trim(),
    name: parts.sublist(1).join(' - ').trim(),
  );
}
