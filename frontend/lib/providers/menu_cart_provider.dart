import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MenuProvider with ChangeNotifier {
  List<Product> _products = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _authToken;

  void update(String? token) {
    _authToken = token;
  }

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_authToken != null) {
        _products = await _apiService.getProducts(_authToken!);
      } else {
        _products = [];
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }
}

class CartProvider with ChangeNotifier {
  List<OrderItem> _items = [];
  final ApiService _apiService = ApiService();
  String? _authToken;

  void update(String? token) {
    _authToken = token;
  }

  List<OrderItem> get items => _items;

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      if (item.product != null) {
         total += item.product!.price * item.quantity;
      }
    }
    return total;
  }

  void addToCart(Product product, int quantity, Map<String, dynamic> modifiers) {
    // Check if item with same productId and modifiers already exists
    int existingIndex = _items.indexWhere((item) => 
      item.productId == product.id && 
      _mapsEqual(item.selectedModifiers, modifiers)
    );

    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity
      );
    } else {
      _items.add(OrderItem(
        productId: product.id,
        quantity: quantity,
        selectedModifiers: modifiers,
        product: product,
      ));
    }
    notifyListeners();
  }

  void incrementQuantity(int index) {
    _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  bool _mapsEqual(Map m1, Map m2) {
    if (m1.length != m2.length) return false;
    for (var key in m1.keys) {
      if (m1[key] != m2[key]) return false;
    }
    return true;
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }

  Order? _lastPlacedOrder;
  Order? get lastPlacedOrder => _lastPlacedOrder;

  Future<String?> placeOrder({required String paymentMethod}) async {
    if (_items.isEmpty) return "Cart is empty";
    if (_authToken == null) return "User not authenticated";
    
    Order order = Order(
      totalAmount: totalAmount,
      paymentStatus: 'paid', // Mock payment
      paymentMethod: paymentMethod,
      status: 'pending',
      items: _items,
    );

    try {
      _lastPlacedOrder = await _apiService.placeOrder(order, _authToken!);
      clearCart();
      notifyListeners();
      return null; // Success
    } catch (e) {
      print(e);
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
