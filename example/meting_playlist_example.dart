import 'package:meting_dart/meting_dart.dart';

void main() async {
  // await kugouPlaylist();
  // await neteasePlaylist();
  await tencentPlaylist();
}

Future<void> neteasePlaylist() async {
  final meting = Meting(server: 'netease')..format(true);
  final playlist = await meting.playlist('7105455116');
  print(playlist);
}

Future<void> kugouPlaylist() async {
  final meting = Meting(server: 'kugou')..format(true);
  final playlist = await meting.playlist('gcid_3z1bsp9mmz3z0ed');
  print(playlist);
}

Future<void> tencentPlaylist() async {
  final meting = Meting(server: 'tencent')..format(true);
  final playlist = await meting.playlist('9346521777');
  print(playlist);
}
