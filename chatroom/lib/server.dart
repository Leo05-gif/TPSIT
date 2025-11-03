import 'dart:io';

late ServerSocket server;

List<ChatClient> clients = [];

void main() {
  ServerSocket.bind(InternetAddress.anyIPv4, 3000).then((ServerSocket socket) {
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
  String? _address;
  int? _port;

  ChatClient(Socket s) {
    _socket = s;
    _address = s.remoteAddress.address;
    _port = s.remotePort;

    _socket.listen(
      messageHandler,
      onError: errorHandler,
      onDone: finishedHandler,
    );
  }

  void messageHandler(data) {
    String message = String.fromCharCodes(data).trim();
    distributeMessage(this, '${_address}:${_port} Message: $message');
  }

  void errorHandler(error) {
    print('${_address}:${_port} Error: $error');
    removeClient(this);
    _socket.close();
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    removeClient(this);
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}
