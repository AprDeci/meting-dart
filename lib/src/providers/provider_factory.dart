import 'package:meting_dart/src/meting.dart';
import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/netease_provider.dart';

class ProviderFactory {
  // static final Map<String, Type> providers = {
  //   'netease': NeteaseProvider,
  // };

  // static BaseProvider create(String platform, Meting meting) {
  //   final provider = providers[platform];
  //   if (provider == null) {
  //     throw Exception('Unsupported platform: $platform');
  //   }
  //   return provider(meting: meting) as BaseProvider;
  // }
  static final Map<String, BaseProvider Function(Meting)> providers = {
    'netease': (meting) => NeteaseProvider(meting: meting),
  };

  static BaseProvider create(String platform, Meting meting) {
    final creator = providers[platform];
    if (creator == null) {
      throw Exception('Unsupported platform: $platform');
    }
    return creator(meting);
  }

  static List<String> get supportedPlatforms => providers.keys.toList();

  static bool isSupported(String platform) => providers.containsKey(platform);
}
