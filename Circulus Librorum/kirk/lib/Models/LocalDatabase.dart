import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'UserModel.dart';
import 'UserTokenModel.dart';
import 'ClubModel.dart';
import 'ClubMembershipModel.dart';
import 'ClubInviteModel.dart';
import 'SessionModel.dart';
import 'TurnModel.dart';
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();
  static Database? _db;
  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }
  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'librorum.db');
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id         INTEGER PRIMARY KEY,
        username   TEXT    NOT NULL UNIQUE,
        password   TEXT    NOT NULL,
        created_at TEXT    NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE user_tokens (
        id         INTEGER NOT NULL,
        token      TEXT    NOT NULL,
        expires_at TEXT    NOT NULL,
        FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE clubs (
        id          INTEGER PRIMARY KEY,
        owner_id    INTEGER NOT NULL,
        name        TEXT    NOT NULL,
        description TEXT    NOT NULL,
        created_at  TEXT    NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE club_memberships (
        user_id   INTEGER NOT NULL,
        club_id   INTEGER NOT NULL,
        joined_in TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE,
        FOREIGN KEY (club_id) REFERENCES clubs(id)  ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE club_invites (
        invite     TEXT    NOT NULL,
        created_by INTEGER NOT NULL,
        club_id    INTEGER NOT NULL,
        expires_at TEXT    NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (club_id)    REFERENCES clubs(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE sessions (
        id          INTEGER PRIMARY KEY,
        club_id     INTEGER NOT NULL,
        book_title  TEXT    NOT NULL,
        description TEXT    NOT NULL,
        completed   INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE turns (
        id         INTEGER PRIMARY KEY,
        session_id INTEGER NOT NULL,
        start      TEXT    NOT NULL,
        end        TEXT    NOT NULL,
        completed  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        operation  TEXT    NOT NULL,
        payload    TEXT    NOT NULL,
        created_at TEXT    NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_queue (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          operation  TEXT    NOT NULL,
          payload    TEXT    NOT NULL,
          created_at TEXT    NOT NULL
        )
      ''');
    }
  }

  Future<void> enqueueOperation(String operation, Map<String, dynamic> payload) async {
    final d = await db;
    await d.insert('sync_queue', {
      'operation':  operation,
      'payload':    jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final d    = await db;
    final rows = await d.query('sync_queue', orderBy: 'id ASC');
    return rows.map((r) => {
      'id':        r['id'],
      'operation': r['operation'],
      'payload':   jsonDecode(r['payload'] as String),
    }).toList();
  }

  Future<void> deleteSyncOperation(int id) async {
    final d = await db;
    await d.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> upsertUser(UserModel user) async {
    final d = await db;
    await d.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<UserModel>> getAllUsers() async {
    final d    = await db;
    final rows = await d.query('users');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<UserModel?> getUser(int id) async {
    final d = await db;
    final rows = await d.query('users', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : UserModel.fromMap(rows.first);
  }
  Future<void> deleteUser(int id) async {
    final d = await db;
    await d.delete('users', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> upsertUserToken(UserTokenModel token) async {
    final d = await db;
    await d.delete('user_tokens', where: 'id = ?', whereArgs: [token.userId]);
    await d.insert('user_tokens', token.toMap());
  }
  Future<UserTokenModel?> getUserToken(int userId) async {
    final d = await db;
    final rows =
        await d.query('user_tokens', where: 'id = ?', whereArgs: [userId]);
    return rows.isEmpty ? null : UserTokenModel.fromMap(rows.first);
  }
  Future<void> deleteUserToken(int userId) async {
    final d = await db;
    await d.delete('user_tokens', where: 'id = ?', whereArgs: [userId]);
  }
  Future<void> upsertClub(ClubModel club) async {
    final d = await db;
    await d.insert('clubs', club.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<ClubModel?> getClub(int id) async {
    final d = await db;
    final rows = await d.query('clubs', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : ClubModel.fromMap(rows.first);
  }
  Future<List<ClubModel>> getAllClubs() async {
    final d = await db;
    final rows = await d.query('clubs');
    return rows.map(ClubModel.fromMap).toList();
  }
  Future<void> deleteClub(int id) async {
    final d = await db;
    await d.delete('clubs', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> upsertMembership(ClubMembershipModel membership) async {
    final d = await db;
    await d.insert('club_memberships', membership.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<ClubMembershipModel>> getMembershipsForUser(int userId) async {
    final d = await db;
    final rows = await d
        .query('club_memberships', where: 'user_id = ?', whereArgs: [userId]);
    return rows.map(ClubMembershipModel.fromMap).toList();
  }
  Future<void> deleteMembership(int userId, int clubId) async {
    final d = await db;
    await d.delete('club_memberships',
        where: 'user_id = ? AND club_id = ?', whereArgs: [userId, clubId]);
  }
  Future<void> upsertInvite(ClubInviteModel invite) async {
    final d = await db;
    await d.insert('club_invites', invite.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<ClubInviteModel?> getInvite(String invite) async {
    final d = await db;
    final rows = await d
        .query('club_invites', where: 'invite = ?', whereArgs: [invite]);
    return rows.isEmpty ? null : ClubInviteModel.fromMap(rows.first);
  }
  Future<void> deleteExpiredInvites() async {
    final d = await db;
    await d.delete('club_invites',
        where: 'expires_at < ?',
        whereArgs: [DateTime.now().toIso8601String()]);
  }
  Future<void> upsertSession(SessionModel session) async {
    final d = await db;
    await d.insert('sessions', session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<SessionModel>> getSessionsForClub(int clubId) async {
    final d = await db;
    final rows =
        await d.query('sessions', where: 'club_id = ?', whereArgs: [clubId]);
    return rows.map(SessionModel.fromMap).toList();
  }
  Future<SessionModel?> getSession(int id) async {
    final d = await db;
    final rows = await d.query('sessions', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : SessionModel.fromMap(rows.first);
  }
  Future<void> deleteSession(int id) async {
    final d = await db;
    await d.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> upsertTurn(TurnModel turn) async {
    final d = await db;
    await d.insert('turns', turn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<TurnModel>> getTurnsForSession(int sessionId) async {
    final d = await db;
    final rows = await d
        .query('turns', where: 'session_id = ?', whereArgs: [sessionId]);
    return rows.map(TurnModel.fromMap).toList();
  }
  Future<TurnModel?> getTurn(int id) async {
    final d = await db;
    final rows = await d.query('turns', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : TurnModel.fromMap(rows.first);
  }
  Future<void> deleteTurn(int id) async {
    final d = await db;
    await d.delete('turns', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> syncClubData({
    required ClubModel club,
    required List<ClubMembershipModel> memberships,
    required List<SessionModel> sessions,
    required List<TurnModel> turns,
  }) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.insert('clubs', club.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (final m in memberships) {
        await txn.insert('club_memberships', m.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final s in sessions) {
        await txn.insert('sessions', s.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final t in turns) {
        await txn.insert('turns', t.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
  Future<void> clearAll() async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.delete('turns');
      await txn.delete('sessions');
      await txn.delete('club_invites');
      await txn.delete('club_memberships');
      await txn.delete('clubs');
      await txn.delete('sync_queue');
      await txn.delete('user_tokens');
      await txn.delete('users');
    });
  }

  Future<void> close() async {
    final d = await db;
    await d.close();
    _db = null;
  }
}