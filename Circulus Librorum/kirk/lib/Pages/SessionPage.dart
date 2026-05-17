import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/ClubModel.dart';
import '../Models/SessionModel.dart';
import '../Models/TurnModel.dart';
import '../Models/UserModel.dart';
import '../Models/UserTokenModel.dart';
import '../Models/LocalDatabase.dart';
import '../Requests/SessionRequests.dart';
import '../Requests/TurnRequests.dart';
import '../Services/SyncService.dart';

class SessionPage extends StatefulWidget {
  final SessionModel session;
  final ClubModel club;
  final UserModel user;
  final UserTokenModel token;
  final bool isOwner;

  const SessionPage({
    super.key,
    required this.session,
    required this.club,
    required this.user,
    required this.token,
    required this.isOwner,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  List<TurnModel> _turns = [];
  late SessionModel _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _loadTurns();
  }

  Future<void> _loadTurns() async {
    setState(() => _loading = true);
    try {
      final res  = await TurnRequests().get(widget.token.token, _session.id);
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final db    = LocalDatabase();
        final List  raw   = body['data'];
        final turns = raw.map((t) => TurnModel.fromMap(t)).toList();
        for (final t in turns) await db.upsertTurn(t);
        setState(() => _turns = turns);
      } else if (body['data'] == null) {
        setState(() => _turns = []);
      } else {
        await _loadFromLocal();
      }
    } catch (_) {
      await _loadFromLocal();
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadFromLocal() async {
    final turns = await LocalDatabase().getTurnsForSession(_session.id);
    setState(() => _turns = turns);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTurn(TurnModel turn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete turn'),
        content: const Text('Delete this turn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await SyncService().tryOrEnqueue(
      operation: 'delete_turn',
      payload: {'club_id': widget.club.id, 'turn_id': turn.id},
      networkCall: () async {
        final res  = await TurnRequests().delete(widget.token.token, widget.club.id, turn.id);
        return jsonDecode(res.body)['success'] == true;
      },
      localUpdate: () => LocalDatabase().deleteTurn(turn.id),
    );

    if (success) {
      _loadTurns();
    } else {
      _showError('Could not delete turn');
    }
  }

  // Only the owner can complete a turn
  Future<void> _completeTurn(TurnModel turn) async {
    final updated = turn.copyWith(completed: true);
    final success = await SyncService().tryOrEnqueue(
      operation: 'complete_turn',
      payload: {'club_id': widget.club.id, 'turn_id': turn.id, 'value': 1},
      networkCall: () async {
        final res  = await TurnRequests().complete(widget.token.token, widget.club.id, turn.id, 1);
        return jsonDecode(res.body)['success'] == true;
      },
      localUpdate: () => LocalDatabase().upsertTurn(updated),
    );

    if (success) {
      _loadTurns();
    } else {
      _showError('Could not complete turn');
    }
  }

  Future<void> _toggleSessionComplete() async {
    final newValue  = _session.completed ? 0 : 1;
    final newModel  = _session.copyWith(completed: newValue == 1);
    final success   = await SyncService().tryOrEnqueue(
      operation: 'complete_session',
      payload: {'club_id': widget.club.id, 'session_id': _session.id, 'value': newValue},
      networkCall: () async {
        final res  = await SessionRequests().complete(
            widget.token.token, widget.club.id, _session.id, newValue);
        return jsonDecode(res.body)['success'] == true;
      },
      localUpdate: () => LocalDatabase().upsertSession(newModel),
    );

    if (success) {
      setState(() => _session = newModel);
    } else {
      _showError('Could not update session');
    }
  }

  void _showAddTurnSheet() {
    final formKey  = GlobalKey<FormState>();
    final fromCtrl = TextEditingController();
    final tillCtrl = TextEditingController();
    bool  loading  = false;

    Future<void> pickDate(TextEditingController ctrl) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        final y = picked.year.toString().substring(2).padLeft(2, '0');
        final m = picked.month.toString().padLeft(2, '0');
        final d = picked.day.toString().padLeft(2, '0');
        ctrl.text = '$y-$m-$d';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('New Turn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fromCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Start date',
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  onTap: () => pickDate(fromCtrl),
                  validator: (v) => (v == null || v.isEmpty) ? 'Pick a start date' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: tillCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'End date',
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  onTap: () => pickDate(tillCtrl),
                  validator: (v) => (v == null || v.isEmpty) ? 'Pick an end date' : null,
                ),
                const SizedBox(height: 20),
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          setSheetState(() => loading = true);

                          final success = await SyncService().tryOrEnqueue(
                            operation: 'create_turn',
                            payload: {
                              'club_id':    widget.club.id,
                              'session_id': _session.id,
                              'from':       fromCtrl.text,
                              'till':       tillCtrl.text,
                            },
                            networkCall: () async {
                              final res = await TurnRequests().create(
                                widget.token.token,
                                widget.club.id,
                                _session.id,
                                fromCtrl.text,
                                tillCtrl.text,
                              );
                              return jsonDecode(res.body)['success'] == true;
                            },
                            localUpdate: () async {},
                          );

                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                          } else {
                            setSheetState(() => loading = false);
                          }
                          if (success) {
                            _loadTurns();
                          } else {
                            _showError('Could not create turn');
                          }
                        },
                        child: const Text('Create'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_session.bookTitle),
        actions: [
          if (widget.isOwner)
            TextButton(
              onPressed: _toggleSessionComplete,
              child: Text(_session.completed ? 'Reopen' : 'Complete'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _session.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _session.completed
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _session.completed ? 'Completed' : 'Active',
                    style: TextStyle(
                      fontSize: 11,
                      color: _session.completed
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
                const Divider(height: 24),
                const Text('Turns',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadTurns,
                    child: _turns.isEmpty
                        ? const Center(child: Text('No turns yet'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _turns.length,
                            itemBuilder: (context, index) {
                              final turn = _turns[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_formatDate(turn.start)}  →  ${_formatDate(turn.end)}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: turn.completed
                                                    ? Colors.green.shade100
                                                    : Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                turn.completed ? 'Read ✓' : 'Pending',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: turn.completed
                                                      ? Colors.green.shade800
                                                      : Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // FIX: complete turn is owner-only
                                      if (!turn.completed && widget.isOwner)
                                        TextButton(
                                          onPressed: () => _completeTurn(turn),
                                          child: const Text('Complete'),
                                        ),
                                      if (widget.isOwner)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 20, color: Colors.grey),
                                          onPressed: () => _deleteTurn(turn),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: widget.isOwner
          ? FloatingActionButton(
              onPressed: _showAddTurnSheet,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}