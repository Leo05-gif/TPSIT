import 'package:flutter/widgets.dart';
import 'package:todosql/card_widget.dart';

class CardNotifier with ChangeNotifier {
  final _cards = <CardWidget>[];
  int _id = 0;

  int get length => _cards.length;

  void addCard() {
    _cards.add(CardWidget(id: _id));
    _id++;
    notifyListeners();
  }

  void deleteCard(int cardId) {
    _cards.removeAt(cardId);
    notifyListeners();
  }

  CardWidget getCard(int i) => _cards[i];
}
