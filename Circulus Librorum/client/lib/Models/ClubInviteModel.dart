class ClubInviteModel {

  final String invite;
  final int createdBy;
  final int clubId;
  final DateTime expiresAt;

  ClubInviteModel({
    required this.invite,
    required this.createdBy,
    required this.clubId,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory ClubInviteModel.fromMap(Map<String, dynamic> map) {
    return ClubInviteModel(
      invite:    map['invite'] as String,
      createdBy: map['created_by'] as int,
      clubId:    map['club_id'] as int,
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invite':     invite,
      'created_by': createdBy,
      'club_id':    clubId,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
  
  @override
  String toString() =>
      'ClubInviteModel(invite: $invite, clubId: $clubId, isExpired: $isExpired)';
}
