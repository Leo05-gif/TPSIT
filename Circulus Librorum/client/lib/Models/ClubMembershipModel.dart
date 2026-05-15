class ClubMembershipModel {

  final int userId;
  final int clubId;
  final DateTime joinedIn;

  ClubMembershipModel({
    required this.userId,
    required this.clubId,
    required this.joinedIn,
  });

  factory ClubMembershipModel.fromMap(Map<String, dynamic> map) {
    return ClubMembershipModel(
      userId:   map['user_id'] as int,
      clubId:   map['club_id'] as int,
      joinedIn: DateTime.parse(map['joined_in'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id':   userId,
      'club_id':   clubId,
      'joined_in': joinedIn.toIso8601String(),
    };
  }
  
  @override
  String toString() =>
      'ClubMembershipModel(userId: $userId, clubId: $clubId, joinedIn: $joinedIn)';
}
