import 'dart:io';

import 'package:chatroom/data/notifiers.dart';
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
    // TODO: implement initState
    super.initState();

    Socket.connect("localhost", 3000).then(
      (Socket sock) {
        socket = sock;
        sock.write("username:${usernameNotifier.value}");
        socket.listen(
          dataHandler,
          onError: errorHandler,
          onDone: doneHandler,
          cancelOnError: false,
        );
      },
      onError: (e) {
        print("Unable to connect: $e");
        exit(1);
      },
    );
    stdin.listen(
      (data) => socket.write(String.fromCharCodes(data).trim() + '\n'),
    );
  }

  void dataHandler(data) {
    setState(() {});
    messages.add(String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    socket.destroy();
    exit(0);
  }

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
