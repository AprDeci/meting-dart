import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const _krcKey = <int>[
  0x40,
  0x47,
  0x61,
  0x77,
  0x5e,
  0x32,
  0x74,
  0x47,
  0x51,
  0x36,
  0x31,
  0x2d,
  0xce,
  0xd2,
  0x6e,
  0x69,
];

String decodeLrcContent(String content) {
  if (content.isEmpty) {
    return '';
  }
  return utf8.decode(base64Decode(content));
}

String decodeKrcContent(String content) {
  if (content.isEmpty) {
    return '';
  }

  final bytes = base64Decode(content);
  if (bytes.length < 4 ||
      bytes[0] != 0x6b ||
      bytes[1] != 0x72 ||
      bytes[2] != 0x63 ||
      bytes[3] != 0x31) {
    return decodeLrcContent(content);
  }

  final body = Uint8List.fromList(bytes.sublist(4));
  for (var i = 0; i < body.length; i++) {
    body[i] = body[i] ^ _krcKey[i % _krcKey.length];
  }

  return utf8.decode(ZLibDecoder().convert(body));
}
