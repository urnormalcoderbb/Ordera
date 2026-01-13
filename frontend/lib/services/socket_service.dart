import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  final String socketUrl = "ws://127.0.0.1:8000/ws/kitchen";
  WebSocketChannel? _channel;
  StreamController? _controller;

  Stream get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  void connect(int restaurantId) {
    _controller ??= StreamController.broadcast();
    try {
      // Use WebSocketChannel.connect which works on all platforms including web
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8000/ws/kitchen?restaurant_id=$restaurantId'),
      );
      _channel?.stream.listen(
        (message) {
          _controller?.add(message);
        },
        onError: (error) {
          print('WebSocket Error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _controller = null;
  }
}
