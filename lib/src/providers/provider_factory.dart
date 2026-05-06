import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/netease_provider.dart';

class ProviderFactory {
  static final Map<String, BaseProvider Function()> providers = {
    'netease': () => NeteaseProvider(),
  };

  static BaseProvider create(String platform) {
    final creator = providers[platform];
    if (creator == null) {
      throw Exception('Unsupported platform: $platform');
    }
    return creator();
  }

  static List<String> get supportedPlatforms => providers.keys.toList();

  static bool isSupported(String platform) => providers.containsKey(platform);
}
