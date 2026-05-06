import 'package:meting_dart/src/meting.dart';

class BaseProvider {
  BaseProvider({this.name = 'base', required this.meting});

  final Meting meting;
  final String name;

  Map<String, dynamic> get header => {};

  void search(String keyword, {Map<String, dynamic> option = const {}}) {
    throw Exception('$name provider must implement search method');
  }
}
