enum HttpMethod { get, post }

enum EncodeType { neteaseEapi }

enum DecodeType {
  neteaseUrl,
  neteaseLyric,
  kugouUrlNew,
  kugouUrlLegacy,
  kugouLyric,
}

class ProviderRequest {
  ProviderRequest({
    required this.url,
    this.method = HttpMethod.get,
    this.body,
    this.encode,
    this.decode,
    this.format,
    this.headerOnly = false,
  });

  String url;
  HttpMethod method;
  Map<String, dynamic>? body;
  EncodeType? encode;
  DecodeType? decode;
  String? format;
  bool headerOnly;
}
