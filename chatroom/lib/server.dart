import 'dart:io';

late ServerSocket server;

List<ChatClient> clients = [];
List<String> usernames = [];

void main() {
  ServerSocket.bind("192.168.1.1", 3000).then((ServerSocket socket) {
    server = socket;
    server.listen((client) {
      handleConnection(client);
    });
  });
}

void handleConnection(Socket client) {
  print(
    'Connection from '
    '${client.remoteAddress.address}:${client.remotePort}',
  );
  clients.add(ChatClient(client));
  client.write(
    "Welcome to dart-chat! "
    "There are ${clients.length - 1} other clients\n",
  );
}

void removeClient(ChatClient client) {
  clients.remove(client);
}

void distributeMessage(ChatClient client, String message) {
  for (ChatClient c in clients) {
    if (c != client) {
      c.write(message + "\n");
    }
  }
}

class ChatClient {
  late Socket _socket;
  String _user = "";

  ChatClient(Socket s) {
    _socket = s;

    _socket.listen(
      messageHandler,
      onError: errorHandler,
      onDone: finishedHandler,
    );
  }

  void messageHandler(data) {
    String message = String.fromCharCodes(data).trim();

    if (message.startsWith("username")) {
      _user = message.split(":").last;

      if (usernames.indexOf(_user) != -1) {
        _socket.close();
      }

      usernames.add(_user);
    } else {
      distributeMessage(this, '${_user}: $message');
    }
  }

  void errorHandler(error) {
    print('${_user}: $error');
    removeClient(this);
    _socket.close();
  }

  void finishedHandler() {
    print('${_user} Disconnected');
    distributeMessage(this, '${_user}: Disconnected');
    removeClient(this);
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}
