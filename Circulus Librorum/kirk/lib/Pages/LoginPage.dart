import 'package:flutter/material.dart';
import '../Models/UserModel.dart';
import '../Models/UserTokenModel.dart';
import '../Models/LocalDatabase.dart';
import '../Requests/UserRequests.dart';
import '../Pages/RegisterPage.dart';
import '../Pages/MainPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await UserRequests().login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (response['success'] != true) {
        _showError(response['message'] ?? 'Login failed');
        return;
      }

      final db = LocalDatabase();

      await db.upsertUser(UserModel.fromMap(response['user']));
      await db.upsertUserToken(
        UserTokenModel.fromMap({
          'id': response['user']['id'],
          'token': response['token'],
          'expires_at': response['expires_at'],
        }),
      );

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Librorum',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => (v == null || v.trim().length < 4)
                      ? 'At least 4 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 4)
                      ? 'At least 4 characters'
                      : null,
                ),
                const SizedBox(height: 32),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
