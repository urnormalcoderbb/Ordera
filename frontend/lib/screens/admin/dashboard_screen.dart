import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../config/design_system.dart';

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
      backgroundColor: OrderaDesign.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrderaDesign.primary),
          onPressed: () => Navigator.pushReplacementNamed(context, '/role_selection'),
        ),
        title: Text('Admin Dashboard', style: OrderaDesign.heading2),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OrderaDesign.primary),
            onPressed: () => Provider.of<OrderProvider>(context, listen: false).fetchOrders(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (ctx, orderData, _) {
          double todayRevenue = 0;
          int todayOrders = 0;
          int activeOrders = 0;
          final today = DateTime.now();
          final formattedDate = DateFormat('EEEE, MMM dd').format(today);

          final recentOrders = orderData.orders.reversed.take(5).toList();

          for (var o in orderData.orders) {
            if (o.status != 'cancelled') {
              if (o.status != 'completed') {
                activeOrders++;
              }
              if (o.createdAt != null &&
                  o.createdAt!.day == today.day &&
                  o.createdAt!.month == today.month &&
                  o.createdAt!.year == today.year) {
                todayRevenue += o.totalAmount;
                todayOrders++;
              }
            }
          }

          double avgOrderValue = todayOrders > 0 ? todayRevenue / todayOrders : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Highlight Card
                _buildMainCard(todayRevenue, todayOrders, formattedDate),
                const SizedBox(height: 24),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatMiniCard('Active Orders', activeOrders.toString(), Icons.pending_actions, Colors.orange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatMiniCard('Avg. Order', '\$${avgOrderValue.toStringAsFixed(1)}', Icons.analytics, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 32),
                
                Text('Quick Actions', style: OrderaDesign.heading2.copyWith(fontSize: 20)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionBtn(
                        label: 'History',
                        icon: Icons.history,
                        color: OrderaDesign.primary,
                        onTap: () => Navigator.pushNamed(context, '/order_history'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickActionBtn(
                        label: 'Menu',
                        icon: Icons.restaurant_menu,
                        color: OrderaDesign.secondary,
                        onTap: () => Navigator.pushNamed(context, '/manage_menu'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Orders', style: OrderaDesign.heading2.copyWith(fontSize: 20)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/order_history'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recentOrders.isEmpty)
                  _buildEmptyRecent()
                else
                  ...recentOrders.map((o) => _RecentOrderTile(order: o)),
                
                const SizedBox(height: 40),
                Center(child: Text('Ordera Pro Admin v1.2', style: OrderaDesign.label.copyWith(fontSize: 10))),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard(double revenue, int count, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: OrderaDesign.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: OrderaDesign.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Revenue', style: OrderaDesign.bodyMedium.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(date, style: OrderaDesign.label.copyWith(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('\$${revenue.toStringAsFixed(2)}',
              style: OrderaDesign.heading1.copyWith(color: Colors.white, fontSize: 44, letterSpacing: -1)),
          const SizedBox(height: 12),
          Text('$count orders placed today', style: OrderaDesign.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: OrderaDesign.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: OrderaDesign.label.copyWith(fontSize: 10), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value, style: OrderaDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: OrderaDesign.cardDecoration,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: OrderaDesign.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text('No orders yet', style: OrderaDesign.bodyMedium),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: OrderaDesign.label.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status == 'ready' ? OrderaDesign.accent : 
                        order.status == 'completed' ? OrderaDesign.textSecondary : OrderaDesign.warning;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: OrderaDesign.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long, color: statusColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.orderNumber ?? order.id}', 
                  style: OrderaDesign.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(order.paymentMethod.toUpperCase(), style: OrderaDesign.label.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${order.totalAmount.toStringAsFixed(2)}', 
                style: OrderaDesign.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: OrderaDesign.primary)),
              const SizedBox(height: 2),
              Text(order.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
