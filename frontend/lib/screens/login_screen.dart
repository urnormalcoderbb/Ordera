import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _restaurantNameController = TextEditingController(); 
  final _cityController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_restaurantNameController.text.isEmpty || _cityController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required')));
       return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    String? error = await auth.login(
      _restaurantNameController.text,
      _cityController.text,
      _usernameController.text,
      _passwordController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
       Navigator.of(context).pushReplacementNamed('/role_selection');
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: OrderaDesign.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderaDesign.background,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OrderaDesign.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OrderaDesign.secondary.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(40),
                decoration: OrderaDesign.cardDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: OrderaDesign.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_menu, color: OrderaDesign.primary, size: 40),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(child: Text("Welcome Back", style: OrderaDesign.heading1)),
                    const SizedBox(height: 8),
                    Center(child: Text("Login to your restaurant dashboard", style: OrderaDesign.bodyMedium)),
                    const SizedBox(height: 40),
                    _buildLabel("Restaurant Name"),
                    _buildTextField(_restaurantNameController, Icons.store, "Enter restaurant name"),
                    const SizedBox(height: 20),
                    _buildLabel("City / Location"),
                    _buildTextField(_cityController, Icons.location_city, "Enter city or branch"),
                    const SizedBox(height: 20),
                    _buildLabel("Username"),
                    _buildTextField(_usernameController, Icons.person_outline, "Enter your username"),
                    const SizedBox(height: 20),
                    _buildLabel("Password"),
                    _buildTextField(_passwordController, Icons.lock_outline, "Enter your password", obscure: true),
                    const SizedBox(height: 40),
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: OrderaDesign.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: _login,
                              child: const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: OrderaDesign.bodyMedium,
                            children: const [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(color: OrderaDesign.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: OrderaDesign.label),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: OrderaDesign.bodyMedium.copyWith(color: OrderaDesign.textSecondary.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: OrderaDesign.textSecondary, size: 20),
        filled: true,
        fillColor: OrderaDesign.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrderaDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}
