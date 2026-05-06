class HttpResult {
  HttpResult({
    this.raw,
    this.statusCode,
    Map<String, List<String>>? headers,
    this.error,
    this.status,
  }) : headers = headers ?? <String, List<String>>{};

  Object? raw;
  int? statusCode;
  Map<String, List<String>> headers;
  Object? error;
  Object? status;

  bool get isOk =>
      error == null &&
      statusCode != null &&
      statusCode! >= 200 &&
      statusCode! < 300;
}
