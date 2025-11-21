import 'dart:io';

import 'package:chatroom/data/notifiers.dart';
import 'package:chatroom/pages/settings_page.dart';
import 'package:chatroom/pages/welcome_page.dart';
import 'package:flutter/material.dart';

class ChatroomPage extends StatefulWidget {
  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  TextEditingController controller = TextEditingController();

  final List<String> messages = [];
  late Socket socket;

  @override
  void initState() {
    super.initState();

    Socket.connect("localhost", 3000).then(
      (Socket sock) {
        socket = sock;
        sock.write("username:${usernameNotifier.value}");
        socket.listen(dataHandler, onError: errorHandler, cancelOnError: false);
      },
      onError: (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return WelcomePage();
            },
          ),
        );
      },
    );
  }

  void dataHandler(data) {
    setState(() {
      messages.add(String.fromCharCodes(data).trim());
    });
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected as ${usernameNotifier.value}'),
        actions: [
          CloseButton(
            onPressed: () {
              socket.destroy();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return WelcomePage();
                  },
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            Divider(thickness: 2.0),
            Expanded(
              child: ValueListenableBuilder<TextStyle>(
                valueListenable: styleTextNotifier,
                builder: (context, style, child) {
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Card(child: Text(messages[index], style: style));
                    },
                  );
                },
              ),
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(border: OutlineInputBorder()),
              onEditingComplete: () {
                socket.write(controller.text + '\n');
                setState(() {
                  messages.add(
                    '${usernameNotifier.value}: ${controller.text} ',
                  );
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
