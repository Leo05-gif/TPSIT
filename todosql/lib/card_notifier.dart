import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'card_model.dart';

class CardNotifier with ChangeNotifier {
  final _cards = <CardModel>[];

  int get length => _cards.length;

  void addCard() {
    _cards.add(CardModel(id: null),);
    notifyListeners();
  }

  void deleteCard(CardModel card) {
    _cards.remove(card);
    notifyListeners();
  }

  CardModel getCard(int i) => _cards[i];
}
