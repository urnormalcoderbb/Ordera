import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/kiosk/kiosk_screen.dart';
import 'screens/kitchen/kitchen_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/manage_menu_screen.dart';
import 'screens/admin/order_history_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MenuProvider>(
          create: (_) => MenuProvider(),
          update: (_, auth, menu) => menu!..update(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) => cart!..update(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, auth, order) => order!..update(auth.token),
        ),
      ],
      child: MaterialApp(
        title: 'Ordera',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        // Start at Login
        home: LoginScreen(), 
        routes: {
          '/login': (ctx) => LoginScreen(),
          '/signup': (ctx) => SignupScreen(),
          '/role_selection': (ctx) => RoleSelectionScreen(),
          '/kiosk': (ctx) => KioskScreen(),
          '/kitchen': (ctx) => KitchenScreen(),
          '/admin': (ctx) => AdminDashboardScreen(),
          '/manage_menu': (ctx) => ManageMenuScreen(),
          '/order_history': (ctx) => OrderHistoryScreen(),
        },
      ),
    );
  }
}
