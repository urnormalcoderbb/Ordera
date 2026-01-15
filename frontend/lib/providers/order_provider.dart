import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  String? _authToken;
  int? _restaurantId;
  bool _isSocketInitialized = false;

  void update(String? token, int? restaurantId) {
    _authToken = token;
    if (_restaurantId != restaurantId) {
      _restaurantId = restaurantId;
      _isSocketInitialized = false; // Reset if restaurant changes
    }
    
    if (_authToken != null && _restaurantId != null && !_isSocketInitialized) {
      initSocket(_restaurantId!);
      _isSocketInitialized = true;
    }
  }

  List<Order> get orders => _orders;

  void initSocket(int restaurantId) {
     print("Initializing Socket for Restaurant: $restaurantId");
     _socketService.connect(restaurantId);
     _socketService.stream.listen((message) {
      print("Socket Received: $message");
      try {
        final data = jsonDecode(message);
        if (data['event'] == 'new_order' || data['event'] == 'order_update') {
          fetchOrders(); 
        }
      } catch (e) {
        print("Error parsing socket message: $e");
      }
    });
  }

  Future<void> fetchOrders() async {
    try {
      if (_authToken != null) {
        print("Fetching fresh orders...");
        _orders = await _apiService.getOrders(_authToken!);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> updateStatus(int orderId, String status, String token) async {
    print("OrderProvider: Updating Order #$orderId to status: $status");
    try {
      await _apiService.updateOrderStatus(orderId, status, token);
      print("OrderProvider: Status update successful for #$orderId");
      // fetchOrders(); // Socket will trigger this for everyone anyway
    } catch (e) {
      print("OrderProvider: Error updating status for #$orderId: $e");
    }
  }
}
