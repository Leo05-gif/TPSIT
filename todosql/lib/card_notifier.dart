import 'package:flutter/material.dart';
import 'card_model.dart';
import 'helper.dart';

class CardNotifier with ChangeNotifier {
  final List<CardModel> _cards = [];
  bool _isInitialized = false;

  CardNotifier() {
    _init();
  }

  int get length => _cards.length;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    await DatabaseHelper.init();
    await _loadCards();
    _isInitialized = true;
  }

  Future<void> _loadCards() async {
    final cards = await DatabaseHelper.getCards();
    _cards
      ..clear()
      ..addAll(cards);
    notifyListeners();
  }

  Future<void> addCard() async {
    final card = CardModel(id: null);
    final id = await DatabaseHelper.insertCard(card);
    card.id = id;

    _cards.insert(0, card);
    notifyListeners();
  }

  Future<void> updateCard(CardModel card) async {
    await DatabaseHelper.updateCard(card);
    notifyListeners();
  }

  Future<void> deleteCard(CardModel card) async {
    _cards.remove(card);
    notifyListeners();
    await DatabaseHelper.deleteCard(card);
  }

  CardModel getCard(int i) => _cards[i];

  Future<void> reload() async {
    await _loadCards();
  }
}
