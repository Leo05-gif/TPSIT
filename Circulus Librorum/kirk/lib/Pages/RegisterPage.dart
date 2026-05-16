import 'package:flutter/material.dart';
import '../Requests/UserRequests.dart';
import '../Pages/LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
      final response = await UserRequests().register(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (response['success'] != true) {
        _showError(response['message'] ?? 'Registration failed');
        return;
      }

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.length < 4)
                      return 'At least 4 characters';
                    if (v != _passwordCtrl.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Register'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
