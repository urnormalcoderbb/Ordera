import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

import '../config/config.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<User?> login(String restaurantName, String city, String username, String password) async {
    print("ApiService: Login started for $username at $restaurantName ($city)");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'restaurant_name': restaurantName,
          'city': city,
          'username': username, 
          'password': password
        }),
      ).timeout(Duration(seconds: 10));

      print("ApiService: Login response ${response.statusCode}");
      print("ApiService: Login body ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User(
          id: 0, 
          username: username, 
          role: data['role'] ?? 'kiosk', 
          token: data['access_token'],
          restaurantId: data['restaurant_id'],
        );
      }
    } catch (e) {
      print("ApiService: Login Error: $e");
    }
    return null;
  }

  Future<bool> verifyPassword(String password, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['authenticated'] ?? false;
      }
    } catch (e) {
      print("ApiService: Verify Password Error: $e");
    }
    return false;
  }

  Future<bool> signup(String restaurantName, String city, String username, String password) async {
    print("ApiService: Signup started");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'restaurant_name': restaurantName,
          'city': city,
          'username': username,
          'password': password
        }),
      ).timeout(Duration(seconds: 10));

      print("ApiService: Signup response ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService: Signup Error: $e");
      return false;
    }
  }

  Future<List<Product>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Category>> getCategories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Category> createCategory(String name, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 200) {
      return Category.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<Category> updateCategory(int id, String name, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 200) {
      return Category.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Failed to update category';
      throw Exception(error);
    }
  }

  Future<void> deleteCategory(int categoryId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Failed to delete category';
      throw Exception(error);
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> productData, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to update product');
    }
  }

 Future<void> deleteProduct(int productId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  Future<String?> uploadImage(List<int> imageBytes, String filename, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
      ));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Upload successful: ${data['image_url']}');
        return data['image_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload error details: $e');
      return null;
    }
  }


  Future<List<Order>> getOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Order> placeOrder(Order order, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to place order';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['error'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<void> updateOrderStatus(int orderId, String status, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status?status_update=$status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }
}
