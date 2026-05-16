import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/UserModel.dart';
import '../Models/UserTokenModel.dart';
import '../Models/ClubModel.dart';
import '../Models/LocalDatabase.dart';
import '../Requests/ClubRequests.dart';

class CreateClubPage extends StatefulWidget {
  final UserModel user;
  final UserTokenModel token;

  const CreateClubPage({super.key, required this.user, required this.token});

  @override
  State<CreateClubPage> createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _descCtrl    = TextEditingController();
  bool _loading      = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
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
      final res  = await ClubRequests().create(
        widget.token.token,
        _nameCtrl.text.trim(),
        _descCtrl.text.trim(),
      );
      final body = jsonDecode(res.body);

      if (body['success'] != true) {
        _showError(body['message'] ?? 'Could not create club');
        return;
      }

      if (body['club_id'] != null) {
        await LocalDatabase().upsertClub(ClubModel(
          id:          body['club_id'] as int,
          ownerId:     widget.user.id,
          name:        _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          createdAt:   DateTime.now(),
        ));
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Club')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Club name'),
                validator: (v) =>
                    (v == null || v.trim().length < 4) ? 'At least 4 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().length < 4) ? 'At least 4 characters' : null,
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Create'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}