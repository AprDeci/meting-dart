abstract interface class MusicProvider {
  String get name;

  Map<String, dynamic> get header;

  void setCookie(String cookie);

  void setFormat(bool enabled);

  Future<Object?> search(
    String keyword, {
    Map<String, dynamic> option = const {},
  });

  Future<Object?> song(String id);

  Future<Object?> album(String id);

  Future<Object?> artist(String id, {int limit = 50});

  Future<Object?> playlist(String id);

  Future<Object?> url(String id, {int br = 320});

  Future<Object?> lyric(String id);

  Future<String> pic(String id, {int size = 300});
}
