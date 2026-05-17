import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../Models/LocalDatabase.dart';
import '../Requests/TurnRequests.dart';
import '../Requests/SessionRequests.dart';
import '../Requests/ClubRequests.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Timer? _timer;
  String? _token;

  void start(String token) {
    _token = token;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _drain());
    _drain();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _token = null;
  }

  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _drain() async {
    if (_token == null) return;
    if (!await isOnline()) return;

    final db  = LocalDatabase();
    final ops = await db.getPendingOperations();

    for (final op in ops) {
      try {
        final success = await _execute(
          op['operation'] as String,
          op['payload'] as Map<String, dynamic>,
        );
        if (success) await db.deleteSyncOperation(op['id'] as int);
      } catch (_) {}
    }
  }

  Future<bool> _execute(String operation, Map<String, dynamic> p) async {
    final t = _token!;
    switch (operation) {
      case 'complete_turn':
        final res = await TurnRequests().complete(t, p['club_id'], p['turn_id'], p['value']);
        return jsonDecode(res.body)['success'] == true;
      case 'complete_session':
        final res = await SessionRequests().complete(t, p['club_id'], p['session_id'], p['value']);
        return jsonDecode(res.body)['success'] == true;
      case 'create_session':
        final res = await SessionRequests().create(t, p['club_id'], p['book_title'], p['description']);
        return jsonDecode(res.body)['success'] == true;
      case 'delete_session':
        final res = await SessionRequests().delete(t, p['club_id'], p['session_id']);
        return jsonDecode(res.body)['success'] == true;
      case 'create_turn':
        final res = await TurnRequests().create(t, p['club_id'], p['session_id'], p['from'], p['till']);
        return jsonDecode(res.body)['success'] == true;
      case 'delete_turn':
        final res = await TurnRequests().delete(t, p['club_id'], p['turn_id']);
        return jsonDecode(res.body)['success'] == true;
      default:
        return true;
    }
  }

  Future<bool> tryOrEnqueue({
    required String operation,
    required Map<String, dynamic> payload,
    required Future<bool> Function() networkCall,
    required Future<void> Function() localUpdate,
  }) async {
    if (await isOnline()) {
      try {
        final success = await networkCall();
        if (success) await localUpdate();
        return success;
      } catch (_) {}
    }
    await localUpdate();
    await LocalDatabase().enqueueOperation(operation, payload);
    return true;
  }
}