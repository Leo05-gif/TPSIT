import 'package:flutter/cupertino.dart';

class Messages extends ChangeNotifier {
  final List<String> _messages = [];

  List<String> get names => List.unmodifiable(_messages);

  void add(String name) {
    _messages.add(name);
    notifyListeners();
  }
}
