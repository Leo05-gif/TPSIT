class SessionModel {

  final int id;
  final int clubId;
  final String bookTitle;
  final String description;
  final bool completed;

  SessionModel({
    required this.id,
    required this.clubId,
    required this.bookTitle,
    required this.description,
    required this.completed,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id:          map['id'] as int,
      clubId:      map['club_id'] as int,
      bookTitle:   map['book_title'] as String,
      description: map['description'] as String,
      completed:   map['completed'] == true || map['completed'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':          id,
      'club_id':     clubId,
      'book_title':  bookTitle,
      'description': description,
      'completed':   completed ? 1 : 0,
    };
  }

  SessionModel copyWith({bool? completed}) {
    return SessionModel(
      id:          id,
      clubId:      clubId,
      bookTitle:   bookTitle,
      description: description,
      completed:   completed ?? this.completed,
    );
  }
  
  @override
  String toString() =>
      'SessionModel(id: $id, clubId: $clubId, bookTitle: $bookTitle, completed: $completed)';
}
