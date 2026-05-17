import 'package:flutter/material.dart';
import '../Models/LocalDatabase.dart';
import '../Requests/ApiClient.dart';
import '../Services/SyncService.dart';
import '../Pages/LoginPage.dart';
import '../Pages/MainPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _ipCtrl   = TextEditingController(text: '192.168.1.');
  final _portCtrl = TextEditingController(text: '8000');
  final _formKey  = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showServerDialog());
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  void _showServerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Server'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ipCtrl,
                decoration: const InputDecoration(labelText: 'IP address'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portCtrl,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (int.tryParse(v.trim()) == null) return 'Must be a number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final ip   = _ipCtrl.text.trim();
              final port = _portCtrl.text.trim();
              ApiClient.baseUrl = 'http://$ip:$port';
              Navigator.of(ctx).pop();
              _resolve();
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _resolve() async {
    final db = LocalDatabase();
    try {
      final allUsers = await db.getAllUsers();
      if (allUsers.isNotEmpty) {
        final user  = allUsers.first;
        final token = await db.getUserToken(user.id);
        if (token != null && !token.isExpired) {
          SyncService().start(token.token);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MainPage(user: user, token: token),
              ),
            );
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}