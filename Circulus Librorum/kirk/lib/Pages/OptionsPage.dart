import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/UserModel.dart';
import '../Models/UserTokenModel.dart';
import '../Models/LocalDatabase.dart';
import '../Requests/ClubRequests.dart';
import '../Pages/LoginPage.dart';
import '../Services/SyncService.dart';

class OptionsPage extends StatelessWidget {
  final UserModel user;
  final UserTokenModel token;

  const OptionsPage({super.key, required this.user, required this.token});

  void _showError(BuildContext context, String message) {
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

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    SyncService().stop();
    await LocalDatabase().clearAll();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  void _showJoinDialog(BuildContext context) {
    final ctrl    = TextEditingController();
    bool  loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Join a club'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Invite code',
              hintText: 'Paste the invite code here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton(
                    onPressed: () async {
                      final invite = ctrl.text.trim();
                      if (invite.isEmpty) return;

                      setDialogState(() => loading = true);
                      try {
                        final res  = await ClubRequests().join(token.token, invite);
                        final body = jsonDecode(res.body);

                        if (ctx.mounted) Navigator.of(ctx).pop();

                        if (body['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Joined club successfully')),
                          );
                          // Pop OptionsPage so MainPage refreshes on return
                          if (context.mounted) Navigator.of(context).pop(true);
                        } else {
                          _showError(context, body['message'] ?? 'Could not join club');
                        }
                      } catch (e) {
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        _showError(context, e.toString());
                      }
                    },
                    child: const Text('Join'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Logged in as ${user.username}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.group_add_outlined),
            title: const Text('Join a club'),
            onTap: () => _showJoinDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}