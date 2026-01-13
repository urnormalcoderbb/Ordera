import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _restaurantNameController = TextEditingController(); 
  final _cityController = TextEditingController(); // New City Controller
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_restaurantNameController.text.isEmpty || _cityController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are required')));
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

    setState(() => _isLoading = false);

    if (error == null) {
       // Navigate to Role Selection
       Navigator.of(context).pushReplacementNamed('/role_selection');
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Welcome Back", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              SizedBox(height: 10),
              Text("Login to manage your restaurant", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 30),
              TextField(
                controller: _restaurantNameController,
                decoration: InputDecoration(
                  labelText: 'Restaurant Name', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City / Branch Location', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 25),
              _isLoading 
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _login,
                      child: Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'),
                child: Text("New here? Create a Restaurant Account", style: TextStyle(color: Colors.deepPurple)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
