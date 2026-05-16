import 'package:flutter/material.dart';
import '../Models/UserModel.dart';
import '../Models/UserTokenModel.dart';

class OptionsPage extends StatelessWidget {
  final UserModel user;
  final UserTokenModel token;

  const OptionsPage({super.key, required this.user, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: const Center(child: Text('Options')),
    );
  }
}