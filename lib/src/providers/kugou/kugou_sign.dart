import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

const _songInfoMd5Key = 'NVPh5oo715z5DIWAeQlhMDsWXXQV4hwt';

String md5Hex(String data) {
  final digest = MD5Digest().process(Uint8List.fromList(utf8.encode(data)));
  return digest.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

String songInfoSignature(Map<String, dynamic> params) {
  final parts =
      params.entries.map((entry) => '${entry.key}=${entry.value}').toList()
        ..sort();
  return md5Hex('$_songInfoMd5Key${parts.join()}$_songInfoMd5Key');
}

String trackerKey(String hash) => md5Hex('${hash}kgcloudv2');
