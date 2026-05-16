class UserModel {

  final int id;
  final String username;
  final String password; 
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id:        map['id'] as int,
      username:  map['username'] as String,
      password:  map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':         id,
      'username':   username,
      'password':   password,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  @override
  String toString() =>
      'UserModel(id: $id, username: $username, createdAt: $createdAt)';
}
