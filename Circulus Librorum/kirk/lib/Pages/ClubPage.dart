import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/ClubModel.dart';
import '../Models/SessionModel.dart';
import '../Models/UserModel.dart';
import '../Models/UserTokenModel.dart';
import '../Models/LocalDatabase.dart';
import '../Requests/ClubRequests.dart';
import '../Requests/SessionRequests.dart';
import '../Pages/SessionPage.dart';

class ClubPage extends StatefulWidget {
  final ClubModel club;
  final UserModel user;
  final UserTokenModel token;
  final bool isOwner;

  const ClubPage({
    super.key,
    required this.club,
    required this.user,
    required this.token,
    required this.isOwner,
  });

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  List<SessionModel> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _loading = true);
    try {
      final res  = await SessionRequests().get(widget.token.token, widget.club.id);
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final db = LocalDatabase();
        final List raw = body['data'];
        final sessions = raw.map((s) => SessionModel.fromMap(s)).toList();
        for (final s in sessions) await db.upsertSession(s);
        setState(() => _sessions = sessions);
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
    final sessions = await LocalDatabase().getSessionsForClub(widget.club.id);
    setState(() => _sessions = sessions);
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

  Future<void> _deleteSession(SessionModel session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete session'),
        content: Text('Delete "${session.bookTitle}"?'),
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

    try {
      final res  = await SessionRequests().delete(
          widget.token.token, widget.club.id, session.id);
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        await LocalDatabase().deleteSession(session.id);
        _loadSessions();
      } else {
        _showError(body['message'] ?? 'Could not delete session');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _showInviteDialog() async {
    try {
      final res  = await ClubRequests().invite(widget.token.token, widget.club.id);
      final body = jsonDecode(res.body);
      if (body['success'] == true && mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Invite code'),
            content: SelectableText(
              body['invite'] ?? '',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        _showError(body['message'] ?? 'Could not generate invite');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showAddSessionSheet() {
    final formKey   = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    bool loading    = false;

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
                const Text('New Session',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Book title'),
                  validator: (v) =>
                      (v == null || v.trim().length < 4) ? 'At least 4 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (v) =>
                      (v == null || v.trim().length < 4) ? 'At least 4 characters' : null,
                ),
                const SizedBox(height: 20),
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          setSheetState(() => loading = true);
                          try {
                            final res = await SessionRequests().create(
                              widget.token.token,
                              widget.club.id,
                              titleCtrl.text.trim(),
                              descCtrl.text.trim(),
                            );
                            final body = jsonDecode(res.body);
                            if (body['success'] == true) {
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              _loadSessions();
                            } else {
                              _showError(body['message'] ?? 'Could not create session');
                            }
                          } catch (e) {
                            _showError(e.toString());
                          } finally {
                            setSheetState(() => loading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.name),
        actions: [
          if (widget.isOwner)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Generate invite',
              onPressed: _showInviteDialog,
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
                  widget.club.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isOwner ? 'You are the owner' : 'Member',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isOwner
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
                const Divider(height: 24),
                const Text('Sessions',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadSessions,
                    child: _sessions.isEmpty
                        ? const Center(child: Text('No sessions yet'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _sessions.length,
                            itemBuilder: (context, index) {
                              final session = _sessions[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SessionPage(
                                          session: session,
                                          club: widget.club,
                                          user: widget.user,
                                          token: widget.token,
                                          isOwner: widget.isOwner,
                                        ),
                                      ),
                                    );
                                    _loadSessions();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      session.bookTitle,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: session.completed
                                                          ? Colors.green.shade100
                                                          : Colors.orange.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      session.completed
                                                          ? 'Done'
                                                          : 'Active',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: session.completed
                                                            ? Colors.green.shade800
                                                            : Colors.orange.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                session.description,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (widget.isOwner) ...[
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline,
                                                size: 20, color: Colors.grey),
                                            onPressed: () =>
                                                _deleteSession(session),
                                          ),
                                        ],
                                      ],
                                    ),
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
              onPressed: _showAddSessionSheet,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}