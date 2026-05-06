import 'package:meting_dart/src/models/provider_request.dart';
import 'package:meting_dart/src/providers/base.dart';

class NeteaseProvider extends BaseProvider {
  NeteaseProvider() : super(name: 'netease');

  @override
  ProviderRequest search(
    String keyword, {
    Map<String, dynamic> option = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  ProviderRequest song(String id) {
    throw UnimplementedError();
  }

  @override
  ProviderRequest album(String id) {
    throw UnimplementedError();
  }

  @override
  ProviderRequest artist(String id, {int limit = 50}) {
    throw UnimplementedError();
  }

  @override
  ProviderRequest playlist(String id) {
    throw UnimplementedError();
  }

  @override
  ProviderRequest url(String id, {int br = 320}) {
    throw UnimplementedError();
  }

  @override
  ProviderRequest lyric(String id) {
    throw UnimplementedError();
  }

  @override
  Future<String> pic(String id, {int size = 300}) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> format(Map<String, dynamic> data) {
    throw UnimplementedError();
  }
}
