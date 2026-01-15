import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    bool success = await auth.signup(
      _restaurantNameController.text.trim(),
      _cityController.text.trim(),
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);

    if (success) {
       Navigator.of(context).pushReplacementNamed('/login');
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful! Please login.')));
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
         content: Text('Signup failed. Username might be taken.'),
         backgroundColor: OrderaDesign.danger,
       ));
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
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OrderaDesign.secondary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OrderaDesign.primary.withOpacity(0.05),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(40),
                decoration: OrderaDesign.cardDecoration,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: OrderaDesign.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.rocket_launch_outlined, color: OrderaDesign.secondary, size: 32),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(child: Text("Create Your Workspace", style: OrderaDesign.heading2)),
                      const SizedBox(height: 8),
                      Center(child: Text("Set up your restaurant onto Ordera", style: OrderaDesign.bodyMedium)),
                      const SizedBox(height: 32),
                      
                      // Tips Panel
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: OrderaDesign.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: OrderaDesign.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            _buildTipRow(Icons.info_outline, "Format: 'Restaurant Name - Area'"),
                            const SizedBox(height: 8),
                            _buildTipRow(Icons.location_on_outlined, "City name only for location field"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel("Restaurant Name"),
                      TextFormField(
                        controller: _restaurantNameController,
                        decoration: OrderaDesign.inputDecoration("e.g. Pizza Palace - Downtown"),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (!val.contains(' - ')) return 'Use: Name - Area';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildLabel("City / Location"),
                      TextFormField(
                        controller: _cityController,
                        decoration: OrderaDesign.inputDecoration("e.g. New York"),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Admin User"),
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: OrderaDesign.inputDecoration("Username"),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Password"),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: OrderaDesign.inputDecoration("Min 6 chars"),
                                  obscureText: true,
                                  validator: (val) => val == null || val.length < 6 ? 'Too short' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                                onPressed: _submit,
                                child: const Text("Get Started", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                          child: RichText(
                            text: TextSpan(
                              text: "Join an existing workspace? ",
                              style: OrderaDesign.bodyMedium,
                              children: const [
                                TextSpan(
                                  text: "Login",
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

  Widget _buildTipRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: OrderaDesign.primary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: OrderaDesign.label.copyWith(fontSize: 12))),
      ],
    );
  }
}
