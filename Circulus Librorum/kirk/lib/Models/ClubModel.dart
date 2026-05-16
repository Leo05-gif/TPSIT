class ClubModel {

  final int id;
  final int ownerId;
  final String name;
  final String description;
  final DateTime createdAt;

  ClubModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory ClubModel.fromMap(Map<String, dynamic> map) {
    return ClubModel(
      id:          map['id'] as int,
      ownerId:     map['owner_id'] as int,
      name:        map['name'] as String,
      description: map['description'] as String,
      createdAt:   DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':          id,
      'owner_id':    ownerId,
      'name':        name,
      'description': description,
      'created_at':  createdAt.toIso8601String(),
    };
  }
  
  @override
  String toString() =>
      'ClubModel(id: $id, ownerId: $ownerId, name: $name)';
}
