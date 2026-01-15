import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/config.dart';

class SocketService {
  // Use the same host as ApiService via AppConfig
  final String _wsBase = AppConfig.wsBaseUrl;
  
  WebSocketChannel? _channel;
  StreamController? _controller;
  int? _currentRestaurantId;

  Stream get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  void connect(int restaurantId) {
    if (_channel != null && _currentRestaurantId == restaurantId) {
      print('SocketService: Already connected to restaurant $restaurantId');
      return;
    }
    
    _currentRestaurantId = restaurantId;
    _controller ??= StreamController.broadcast();
    
    final wsUrl = '$_wsBase/ws/kitchen?restaurant_id=$restaurantId';
    print('SocketService: Connecting to $wsUrl');
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel?.stream.listen(
        (message) {
          _controller?.add(message);
        },
        onError: (error) {
          print('SocketService Error: $error');
          _reconnect(restaurantId);
        },
        onDone: () {
          print('SocketService: Connection closed');
          // Optional: handle reconnect logic here if needed
        },
      );
    } catch (e) {
      print('SocketService: Connection failed: $e');
    }
  }

  void _reconnect(int restaurantId) {
    _channel?.sink.close();
    _channel = null;
    Future.delayed(Duration(seconds: 5), () => connect(restaurantId));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _currentRestaurantId = null;
    _controller?.close();
    _controller = null;
  }
}
