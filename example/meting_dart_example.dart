import 'package:meting_dart/meting_dart.dart';

void main() async {
  await neteaseExample();
}

Future<void> neteaseExample() async {
  final meting = Meting(server: 'netease')..format(true);
  final searchFuture = await meting.search('晚安-颜人中', option: {'limit': 10});
  print(searchFuture);
  print("-----------------");
  final song = await meting.song('1359356908');
  print(song);
  print("-----------------");
  final picture = await meting.pic('109951170473693123');
  print(picture);
  print("-----------------");
  final lyric = await meting.lyric('2731571357');
  print(lyric);
  print("-----------------");
}
