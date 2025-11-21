import 'package:chatroom/data/constants.dart';
import 'package:chatroom/data/notifiers.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextStyle? menuItem = KTextStyle.defaultText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
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
            Stack(
              children: [
                Text('Font Size'),
                DropdownButton(
                  value: menuItem,
                  isExpanded: true,
                  autofocus: false,
                  items: [
                    DropdownMenuItem(
                      value: KTextStyle.smallText,
                      child: Text('small'),
                    ),
                    DropdownMenuItem(
                      value: KTextStyle.defaultText,
                      child: Text('default'),
                    ),
                    DropdownMenuItem(
                      value: KTextStyle.bigText,
                      child: Text('big'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      menuItem = value;
                      styleTextNotifier.value = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
