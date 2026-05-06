Map<String, String> parseCookie(String cookie) {
  final result = <String, String>{};
  for (final part in cookie.split(';')) {
    final index = part.indexOf('=');
    if (index <= 0) {
      continue;
    }
    result[part.substring(0, index).trim()] = part.substring(index + 1).trim();
  }
  return result;
}
