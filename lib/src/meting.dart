import 'package:dio/dio.dart';
import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/provider_factory.dart';

class Meting {
  Meting({String server = 'netease', Dio? dio})
    : server = server,
      dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              responseType: ResponseType.plain,
              validateStatus: (_) => true,
            ),
          ) {
    site(server);
  }

  final String version = '__VERSION__';
  final Dio dio;

  bool isFormat = false;
  String? _cookie;

  String server;
  late BaseProvider provider;

  Map<String, dynamic> get header => provider.header;

  Meting site(String server) {
    if (!ProviderFactory.isSupported(server)) {
      server = 'netease';
    }
    this.server = server;
    provider = ProviderFactory.create(server, dio);
    provider.setFormat(isFormat);
    final cookie = _cookie;
    if (cookie != null && cookie.isNotEmpty) {
      provider.setCookie(cookie);
    }
    return this;
  }

  Meting cookie(String cookie) {
    _cookie = cookie;
    provider.setCookie(cookie);
    return this;
  }

  Meting format(bool isFormat) {
    this.isFormat = isFormat;
    provider.setFormat(isFormat);
    return this;
  }

  Future<Object?> search(
    String keyword, {
    Map<String, dynamic> option = const {},
  }) async {
    return provider.search(keyword, option: option);
  }

  Future<Object?> song(String id) async {
    return provider.song(id);
  }

  Future<Object?> album(String id) async {
    return provider.album(id);
  }

  Future<Object?> artist(String id, {int limit = 50}) async {
    return provider.artist(id, limit: limit);
  }

  Future<Object?> playlist(String id) async {
    return provider.playlist(id);
  }

  Future<Object?> url(String id, {int br = 320}) async {
    return provider.url(id, br: br);
  }

  Future<Object?> lyric(String id) async {
    return provider.lyric(id);
  }

  Future<String> pic(String id, {int size = 300}) {
    return provider.pic(id, size: size);
  }

  static List<String> getSupportedPlatforms() {
    return ProviderFactory.supportedPlatforms;
  }

  static bool isSupported(String platform) {
    return ProviderFactory.isSupported(platform);
  }
}
