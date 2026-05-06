import 'package:meting_dart/src/providers/base.dart';
import 'package:meting_dart/src/providers/provider_factory.dart';

class Meting {
  final String version;
  Map<String, dynamic> raw;
  Map<String, dynamic> info;
  Map<String, dynamic> error;
  int status;
  Map<String, dynamic> temp;
  String server;
  BaseProvider provider;
  bool isFormat;
  Map<String, dynamic> header;

  Meting({
    this.version = '__VERSION__',
    required this.raw,
    required this.info,
    required this.error,
    required this.status,
    required this.temp,
    required this.server,
    required this.provider,
    required this.isFormat,
    required this.header,
  });

  void site(String server) {
    if (!ProviderFactory.isSupported(server)) {
      server = 'netease';
    }
    this.server = server;
    provider = ProviderFactory.create(server, this);
  }
}
