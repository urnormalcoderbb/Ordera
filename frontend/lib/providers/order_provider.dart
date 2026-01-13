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

  void update(String? token) {
    _authToken = token;
  }

  List<Order> get orders => _orders;

  void initSocket(int restaurantId) {
     _socketService.connect(restaurantId);
     _socketService.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['event'] == 'new_order' || data['event'] == 'order_update') {
        fetchOrders(); 
      }
    });
  }

  Future<void> fetchOrders() async {
    try {
      if (_authToken != null) {
        _orders = await _apiService.getOrders(_authToken!);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateStatus(int orderId, String status, String token) async {
    try {
      await _apiService.updateOrderStatus(orderId, status, token);
      fetchOrders();
    } catch (e) {
      print(e);
    }
  }
}
