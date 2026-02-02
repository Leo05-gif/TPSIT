class TodoModel {
  TodoModel({required this.id, required this.name, required this.checked, required this.cardId});
  final int? id;
  String name;
  bool checked;
  int? cardId;

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'checked': checked ? 1 : 0, 'cardId': cardId};
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(id: map['id'], name: map['name'], checked: map['checked'] == 1, cardId: map['cardId']);
  }

}
