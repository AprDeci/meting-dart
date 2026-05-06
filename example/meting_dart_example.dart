import 'package:meting_dart/meting_dart.dart';

void main() async {
  await neteaseExample();
  await kugouExample();
}

Future<void> neteaseExample() async {
  final meting = Meting(server: 'netease')..format(true);
  print(
    "-------------------------------Netease Example----------------------------------",
  );
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

Future<void> kugouExample() async {
  final meting = Meting(server: 'kugou')..format(false);
  print(
    "-------------------------------Kugou Example----------------------------------",
  );
  final result = await meting.search('Love Like This', option: {'limit': 3});
  print(result);
  print("-----------------");
  final song = await meting.song('ec8eb73e83c6e2a2b58b55a3a21c1296');
  print(song);
  print("-----------------");
  final lyric = await meting.lyric('ec8eb73e83c6e2a2b58b55a3a21c1296');
  print(lyric);
  print("-----------------");
  final picture = await meting.pic('ec8eb73e83c6e2a2b58b55a3a21c1296');
  print(picture);
  print("-----------------");
}
