import 'package:chatroom/data/notifiers.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          CheckboxListTile(
            value: isDarkNotifier.value,
            title: Text('Change Theme'),
            onChanged: (value) {
              setState(() {
                isDarkNotifier.value = !isDarkNotifier.value;
              });
            },
          ),
        ],
      ),
    );
  }
}
