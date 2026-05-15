class UserTokenModel {
  final int userId;       
  final String token;
  final DateTime expiresAt;

  UserTokenModel({
    required this.userId,
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory UserTokenModel.fromMap(Map<String, dynamic> map) {
    return UserTokenModel(
      userId:    map['id'] as int,
      token:     map['token'] as String,
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':         userId,
      'token':      token,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
  
  @override
  String toString() =>
      'UserTokenModel(userId: $userId, expiresAt: $expiresAt, isExpired: $isExpired)';
}
