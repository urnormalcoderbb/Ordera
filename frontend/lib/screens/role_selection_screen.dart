import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'kiosk/kiosk_screen.dart';
import 'kitchen/kitchen_screen.dart';
import 'admin/dashboard_screen.dart';
import '../services/api_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.purple.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ordera',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Montserrat', // Make sure to add font or use default
                ),
              ),
              SizedBox(height: 10),
              Text(
                'One App. Three Identities.',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
              SizedBox(height: 60),
              _RoleCard(
                title: 'Kiosk Mode',
                icon: Icons.touch_app,
                color: Colors.orange,
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).setMachineRole('kiosk');
                  Navigator.push(context, MaterialPageRoute(builder: (_) => KioskScreen()));
                },
              ),
              SizedBox(height: 20),
              _RoleCard(
                title: 'Kitchen Display',
                icon: Icons.kitchen,
                color: Colors.green,
                onTap: () => _authenticateAndNavigate(context, 'kitchen'),
              ),
              SizedBox(height: 20),
              _RoleCard(
                title: 'Admin Dashboard',
                icon: Icons.dashboard,
                color: Colors.blue,
                onTap: () => _authenticateAndNavigate(context, 'admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _authenticateAndNavigate(BuildContext context, String role) async {
    final userController = TextEditingController();
    final passController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final authenticated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Admin Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please verify admin credentials to enter ${role == 'admin' ? 'Dashboard' : 'Kitchen'}.'),
            SizedBox(height: 15),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Admin Username', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final username = userController.text.trim().toLowerCase();
              final password = passController.text;

              if (username != auth.user?.username?.toLowerCase()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid admin username')));
                return;
              }

              final isValid = await ApiService().verifyPassword(password, auth.token!);
              if (isValid) {
                Navigator.pop(ctx, true);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Invalid admin password')));
              }
            },
            child: Text('Verify'),
          ),
        ],
      ),
    );

    if (authenticated == true) {
      if (role == 'kitchen') {
        if (auth.user?.restaurantId != null) {
          Provider.of<OrderProvider>(context, listen: false).initSocket(auth.user!.restaurantId!);
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => KitchenScreen()));
      } else {
        auth.setMachineRole('admin');
        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboardScreen()));
      }
    }
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
