import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderaDesign.background,
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEEF2FF),
                    Color(0xFFF5F3FF),
                    Color(0xFFFDF2F8),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: OrderaDesign.primary.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.restaurant_menu, color: OrderaDesign.primary, size: 60),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Ordera',
                  style: OrderaDesign.heading1.copyWith(fontSize: 48, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                Text(
                  'One App. Three Identities.',
                  style: OrderaDesign.bodyLarge.copyWith(color: OrderaDesign.textSecondary),
                ),
                const SizedBox(height: 60),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _RoleCard(
                      title: 'Kiosk Mode',
                      subtitle: 'Customer self-service ordering',
                      icon: Icons.touch_app_outlined,
                      color: OrderaDesign.primary,
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false).setMachineRole('kiosk');
                        Navigator.pushNamed(context, '/kiosk');
                      },
                    ),
                    _RoleCard(
                      title: 'Kitchen Display',
                      subtitle: 'Real-time order management',
                      icon: Icons.kitchen_outlined,
                      color: OrderaDesign.accent,
                      onTap: () => _authenticateAndNavigate(context, 'kitchen'),
                    ),
                    _RoleCard(
                      title: 'Admin Panel',
                      subtitle: 'Analytics & menu control',
                      icon: Icons.auto_graph_outlined,
                      color: OrderaDesign.secondary,
                      onTap: () => _authenticateAndNavigate(context, 'admin'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _authenticateAndNavigate(BuildContext context, String role) async {
    final userController = TextEditingController();
    final passController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final authenticated = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: anim1,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Column(
              children: [
                Icon(Icons.lock_person_outlined, color: OrderaDesign.primary, size: 48),
                const SizedBox(height: 16),
                Text('Admin Access', style: OrderaDesign.heading2),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verify credentials to enter ${role == 'admin' ? 'Dashboard' : 'Kitchen'}.',
                  textAlign: TextAlign.center,
                  style: OrderaDesign.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: userController,
                  decoration: _inputDecoration('Admin Username', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: _inputDecoration('Password', Icons.lock_outline),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: OrderaDesign.textSecondary)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrderaDesign.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final username = userController.text.trim();
                  final password = passController.text;

                  if (username != auth.user?.username) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid admin username'), backgroundColor: OrderaDesign.danger),
                    );
                    return;
                  }

                  final isValid = await ApiService().verifyPassword(password, auth.token!);
                  if (isValid) {
                    Navigator.pop(ctx, true);
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Invalid password'), backgroundColor: OrderaDesign.danger),
                    );
                  }
                },
                child: const Text('Verify Account'),
              ),
            ],
          ),
        );
      },
    );

    if (authenticated == true) {
      if (role == 'kitchen') {
        Navigator.pushNamed(context, '/kitchen');
      } else {
        auth.setMachineRole('admin');
        Navigator.pushNamed(context, '/admin');
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _isHovering 
                  ? widget.color.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.05),
                blurRadius: _isHovering ? 30 : 20,
                offset: Offset(0, _isHovering ? 15 : 10),
              ),
            ],
            border: Border.all(
              color: _isHovering ? widget.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: OrderaDesign.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: OrderaDesign.bodyMedium.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
