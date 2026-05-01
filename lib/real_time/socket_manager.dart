import 'dart:convert';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketManager {
  static final Set<WebSocketChannel> clients = {};

  static final handler = webSocketHandler((WebSocketChannel socket, String? protocol) {
    clients.add(socket);

    socket.stream.listen(
      (_) {},
      onDone: () {
        clients.remove(socket);
      },
      onError: (_) {
        clients.remove(socket);
      },
    );
  });

  static void broadcast(Map data) {
    final message = jsonEncode(data);

    for (final client in clients) {
      client.sink.add(message);
    }
  }
}