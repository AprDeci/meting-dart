import 'dart:convert';

Map<String, String> decodeTencentLyric(String result) {
  final jsonStr = _unwrapJsonp(result);
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;
  return {
    'lyric': _decodeLyricField(data['lyric']),
    'tlyric': _decodeLyricField(data['trans']),
  };
}

String _unwrapJsonp(String value) {
  final start = value.indexOf('(');
  final end = value.lastIndexOf(')');
  if (start >= 0 && end > start) {
    return value.substring(start + 1, end);
  }
  return value;
}

String _decodeLyricField(Object? value) {
  final encoded = value?.toString() ?? '';
  if (encoded.isEmpty) {
    return '';
  }
  return decodeHtmlEntities(utf8.decode(base64Decode(encoded)));
}

String decodeHtmlEntities(String text) {
  final named = {
    '&apos;': "'",
    '&quot;': '"',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&nbsp;': ' ',
  };
  var decoded = text;
  for (final entry in named.entries) {
    decoded = decoded.replaceAll(entry.key, entry.value);
  }
  decoded = decoded.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    return String.fromCharCode(int.parse(match.group(1)!));
  });
  decoded = decoded.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
    return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
  });
  return decoded;
}
