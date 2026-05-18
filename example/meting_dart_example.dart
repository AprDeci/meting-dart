import 'package:meting_dart/meting_dart.dart';

void main() async {
  //await neteaseExample();
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
  final lyric = await meting.lyric('1824020871');
  print(lyric);
  print("-----------------");
}

Future<void> kugouExample() async {
  final meting = Meting(server: 'kugou')..format(false);
  print(
    "-------------------------------Kugou Example----------------------------------",
  );
  final result = await meting.search('稻香-周杰伦', option: {'limit': 3});
  print(result);
  print("-----------------");
  final song = await meting.song('8909e1809908cd8e3bf6cf85d98b93f0');
  print(song);
  print("-----------------");
  final lyric = await meting.lyric('8909e1809908cd8e3bf6cf85d98b93f0');
  print(lyric);
  print("-----------------");
  final picture = await meting.pic('8909e1809908cd8e3bf6cf85d98b93f0');
  print(picture);
  print("-----------------");
}
