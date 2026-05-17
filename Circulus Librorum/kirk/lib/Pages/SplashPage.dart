import 'package:flutter/material.dart';
import '../Models/LocalDatabase.dart';
import '../Services/SyncService.dart';
import '../Pages/LoginPage.dart';
import '../Pages/MainPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final db = LocalDatabase();

    // Look for any stored user + token
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