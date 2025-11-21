import 'package:chatroom/data/notifiers.dart';
import 'package:flutter/material.dart';

class ChatroomPage extends StatelessWidget {
  const ChatroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Connected as ${usernameNotifier.value}'),
          Container(),
          TextField(),
        ],
      ),
    );
  }
}
