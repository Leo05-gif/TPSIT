import 'package:chatroom/data/notifiers.dart';
import 'package:flutter/material.dart';

class ChatroomPage extends StatefulWidget {
  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  TextEditingController controller = TextEditingController();

  final List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            Text('Connected as ${usernameNotifier.value}'),
            Divider(thickness: 2.0),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Text(messages[index]);
                },
              ),
            ),
            TextField(
              controller: controller,
              onEditingComplete: () {
                setState(() {
                  messages.add(controller.text);
                  controller.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
