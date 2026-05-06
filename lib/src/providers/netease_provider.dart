import 'package:meting_dart/src/providers/base.dart';

class NeteaseProvider extends BaseProvider {
  NeteaseProvider({required super.dio})
    : super(name: 'netease', header: _defaultHeader);

  static const Map<String, dynamic> _defaultHeader = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0 Safari/537.36',
    'Referer': 'https://music.163.com/',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Cookie': 'os=pc; appver=8.9.70;',
  };

  @override
  Future<Object?> search(
    String keyword, {
    Map<String, dynamic> option = const {},
  }) {
    throw UnimplementedError('Netease search is not implemented yet');
  }

  @override
  Future<Object?> song(String id) {
    throw UnimplementedError('Netease song is not implemented yet');
  }

  @override
  Future<Object?> album(String id) {
    throw UnimplementedError('Netease album is not implemented yet');
  }

  @override
  Future<Object?> artist(String id, {int limit = 50}) {
    throw UnimplementedError('Netease artist is not implemented yet');
  }

  @override
  Future<Object?> playlist(String id) {
    throw UnimplementedError('Netease playlist is not implemented yet');
  }

  @override
  Future<Object?> url(String id, {int br = 320}) {
    throw UnimplementedError('Netease url is not implemented yet');
  }

  @override
  Future<Object?> lyric(String id) {
    throw UnimplementedError('Netease lyric is not implemented yet');
  }

  @override
  Future<String> pic(String id, {int size = 300}) {
    throw UnimplementedError('Netease pic is not implemented yet');
  }
}
