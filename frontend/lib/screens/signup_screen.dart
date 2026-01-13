import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _cityController = TextEditingController(); // Added
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    bool success = await auth.signup(
      _restaurantNameController.text,
      _cityController.text,
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
       // Navigate to login or auto-login
       Navigator.of(context).pushReplacementNamed('/login');
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup successful! Please login.')));
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed. Username might be taken.')));
    }
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 12)),
          SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Create Account", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                SizedBox(height: 10),
                Text("Start your digital restaurant journey", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 20),
                // Instructions Panel
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                          SizedBox(width: 8),
                          Text("Quick Tips", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildTip("🏪", "Restaurant Name: Include your restaurant name + area (e.g., 'Pizza Palace - Downtown')"),
                      _buildTip("📍", "Location: Enter only your city name (e.g., 'New York')"),
                      _buildTip("👤", "Username: This will be your admin login (e.g., 'admin' or your name)"),
                      _buildTip("🔒", "Password: Minimum 6 characters, keep it secure!"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _restaurantNameController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name', 
                    hintText: 'e.g., Pizza Palace - Downtown',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (!val.contains(' - ')) return 'Format must be: Name - Area';
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City / Location', 
                    hintText: 'e.g., New York',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Admin Username', 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person_add),
                  ),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password', 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
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
                        onPressed: _submit,
                        child: Text("Create Restaurant", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: Text("Already have an account? Login", style: TextStyle(color: Colors.deepPurple)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
