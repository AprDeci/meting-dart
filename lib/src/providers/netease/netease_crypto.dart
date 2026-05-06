import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

const String eapiKey = 'e82ckenh8dichen8';

String eapiPath(String url) {
  final uri = Uri.parse(url);
  final path = uri.hasScheme ? uri.path : url;
  return path.replaceFirst('/api/', '/eapi/');
}

String eapiEncrypt(String url, Map<String, dynamic> body) {
  final path = Uri.parse(url).hasScheme ? Uri.parse(url).path : url;
  final jsonBody = jsonEncode(body);
  final message = 'nobody${path}use${jsonBody}md5forencrypt';
  final digest = _md5Hex(message);
  final data = '$path-36cd479b6b5-$jsonBody-36cd479b6b5-$digest';
  return _aesEcbEncryptToHex(data, eapiKey).toUpperCase();
}

String encryptCoverId(String id) {
  final key = utf8.encode(r'3go8&$8*3*3h0k(2)2');
  final bytes = utf8.encode(id);
  final xored = List<int>.generate(
    bytes.length,
    (index) => bytes[index] ^ key[index % key.length],
  );
  final digest = MD5Digest().process(Uint8List.fromList(xored));
  return base64Encode(digest).replaceAll('/', '_').replaceAll('+', '-');
}

String _aesEcbEncryptToHex(String data, String key) {
  final cipher =
      PaddedBlockCipherImpl(PKCS7Padding(), ECBBlockCipher(AESEngine()))..init(
        true,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          KeyParameter(Uint8List.fromList(utf8.encode(key))),
          null,
        ),
      );
  final encrypted = cipher.process(Uint8List.fromList(utf8.encode(data)));
  return encrypted.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

String _md5Hex(String data) {
  final digest = MD5Digest().process(Uint8List.fromList(utf8.encode(data)));
  return digest.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
