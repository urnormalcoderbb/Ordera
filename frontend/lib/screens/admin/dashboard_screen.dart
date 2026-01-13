import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<OrderProvider>(context, listen: false).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manager Dashboard')),
      body: Consumer<OrderProvider>(
        builder: (ctx, orderData, _) {
          double totalSales = 0;
          final today = DateTime.now();
          final formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(today);

          for (var o in orderData.orders) {
            // Only count today's orders that aren't cancelled
            if (o.status != 'cancelled' && o.createdAt != null) {
              if (o.createdAt!.day == today.day &&
                  o.createdAt!.month == today.month &&
                  o.createdAt!.year == today.year) {
                totalSales += o.totalAmount;
              }
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('Dashboard Overview',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.analytics_outlined,
                              color: Colors.white70, size: 28),
                          Text('Sales Report',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(formattedDate,
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 5),
                      Text('\$${totalSales.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold)),
                      Text('Today\'s Revenue',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                child: Text('Quick Actions',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    child: Icon(Icons.history, color: Colors.deepPurple),
                  ),
                  title: Text('Order History', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('View past orders and sales details'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/order_history'),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: Icon(Icons.restaurant_menu, color: Colors.orange),
                  ),
                  title: Text('Manage Menu', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Add categories and products'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/manage_menu'),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Ordera Manager v1.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
