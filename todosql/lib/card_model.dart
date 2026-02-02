class CardModel {
  CardModel({required this.id});
  
  int? id;

  Map<String, dynamic> toMap() {
    return {'id': id};
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(id: map['id']);
  }
}
