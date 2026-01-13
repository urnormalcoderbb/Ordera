import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  String? get token => _user?.token; // Added token getter

  Future<String?> login(String restaurantName, String city, String username, String password) async {
    try {
      _user = await _apiService.login(restaurantName, city, username, password);
      // If backend returns role='admin', we honor it.
      // If kisk/kitchen logic depends on it, allow Role Selection.
      notifyListeners();
      if (_user != null) return null; // Success
      return "Invalid Credentials";
    } catch (e) {
      return "Network Error: $e";
    }
  }

  Future<bool> signup(String restaurantName, String city, String username, String password) async {
    try {
      return await _apiService.signup(restaurantName, city, username, password);
    } catch (e) {
      return false; // Return false on network error so UI stops loading
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  // Temporary method to set role for demo purposes (e.g. Kiosk/Kitchen don't strictly require login in this prototype)
  void setMachineRole(String role) {
    if (_user == null) {
      // Create a dummy user for the session
      _user = User(id: 0, username: 'Device', role: role);
    } 
    notifyListeners();
  }
}
