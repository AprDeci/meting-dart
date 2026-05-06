import 'package:dio/dio.dart';
import 'package:meting_dart/src/providers/music_provider.dart';

abstract class BaseProvider implements MusicProvider {
  BaseProvider({
    required this.name,
    required this.dio,
    Map<String, dynamic>? header,
  }) : _header = Map<String, dynamic>.from(header ?? const {});

  @override
  final String name;

  final Dio dio;

  final Map<String, dynamic> _header;

  bool isFormat = false;

  @override
  Map<String, dynamic> get header => Map<String, dynamic>.unmodifiable(_header);

  @override
  void setCookie(String cookie) {
    final current = _header['Cookie']?.toString();
    if (current == null || current.isEmpty) {
      _header['Cookie'] = cookie;
      return;
    }

    if (cookie.isEmpty) {
      return;
    }

    _header['Cookie'] = '$current; $cookie';
  }

  @override
  void setFormat(bool enabled) {
    isFormat = enabled;
  }

  @override
  Future<Object?> search(
    String keyword, {
    Map<String, dynamic> option = const {},
  }) {
    throw UnimplementedError('$name search is not implemented yet');
  }

  @override
  Future<Object?> song(String id) {
    throw UnimplementedError('$name song is not implemented yet');
  }

  @override
  Future<Object?> album(String id) {
    throw UnimplementedError('$name album is not implemented yet');
  }

  @override
  Future<Object?> artist(String id, {int limit = 50}) {
    throw UnimplementedError('$name artist is not implemented yet');
  }

  @override
  Future<Object?> playlist(String id) {
    throw UnimplementedError('$name playlist is not implemented yet');
  }

  @override
  Future<Object?> url(String id, {int br = 320}) {
    throw UnimplementedError('$name url is not implemented yet');
  }

  @override
  Future<Object?> lyric(String id) {
    throw UnimplementedError('$name lyric is not implemented yet');
  }

  @override
  Future<String> pic(String id, {int size = 300}) {
    throw UnimplementedError('$name pic is not implemented yet');
  }
}
