import 'package:dio/dio.dart';
import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/netease_provider.dart';

class ProviderFactory {
  static final Map<String, BaseProvider Function(Dio dio)> providers = {
    'netease': (dio) => NeteaseProvider(dio: dio),
  };

  static BaseProvider create(String platform, Dio dio) {
    final creator = providers[platform];
    if (creator == null) {
      throw Exception('Unsupported platform: $platform');
    }
    return creator(dio);
  }

  static List<String> get supportedPlatforms => providers.keys.toList();

  static bool isSupported(String platform) => providers.containsKey(platform);
}
