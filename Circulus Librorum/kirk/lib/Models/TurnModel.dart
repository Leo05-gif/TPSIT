class TurnModel {

  final int id;
  final int sessionId;
  final DateTime start;
  final DateTime end;
  final bool completed;

  TurnModel({
    required this.id,
    required this.sessionId,
    required this.start,
    required this.end,
    required this.completed,
  });

  factory TurnModel.fromMap(Map<String, dynamic> map) {
    return TurnModel(
      id:        map['id'] as int,
      sessionId: map['session_id'] as int,
      start:     _parseDate(map['start'] as String),
      end:       _parseDate(map['end'] as String),
      completed: map['completed'] == true || map['completed'] == 1,
    );
  }

  static DateTime _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      final parts = value.split('-');
      if (parts.length == 3 && parts[0].length == 2) {
        return DateTime.parse('20${parts[0]}-${parts[1]}-${parts[2]}');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id':         id,
      'session_id': sessionId,
      'start':      start.toIso8601String(),
      'end':        end.toIso8601String(),
      'completed':  completed ? 1 : 0,
    };
  }

  TurnModel copyWith({bool? completed}) {
    return TurnModel(
      id:        id,
      sessionId: sessionId,
      start:     start,
      end:       end,
      completed: completed ?? this.completed,
    );
  }
  
  @override
  String toString() =>
      'TurnModel(id: $id, sessionId: $sessionId, start: $start, end: $end, completed: $completed)';
}
