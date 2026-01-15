import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/models.dart';
import 'package:intl/intl.dart';
import '../../config/design_system.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order History', style: OrderaDesign.heading2),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (ctx, orderData, _) {
          final orders = orderData.orders.reversed.toList(); 

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 80, color: OrderaDesign.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No orders found', style: OrderaDesign.bodyMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final order = orders[i];
              return _OrderHistoryCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final Order order;
  const _OrderHistoryCard({required this.order});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return OrderaDesign.warning;
      case 'preparing': return OrderaDesign.primary;
      case 'ready': return OrderaDesign.accent;
      case 'completed': return OrderaDesign.textSecondary;
      case 'cancelled': return OrderaDesign.danger;
      default: return OrderaDesign.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final dateStr = order.createdAt != null ? dateFormat.format(order.createdAt!) : 'Just now';
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: OrderaDesign.cardDecoration,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 20),
        ),
        title: Text(
          'Order #${order.orderNumber ?? order.id}', 
          style: OrderaDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(dateStr, style: OrderaDesign.label),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${order.totalAmount.toStringAsFixed(2)}', style: OrderaDesign.bodyLarge.copyWith(color: OrderaDesign.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(order.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: OrderaDesign.label),
                const SizedBox(height: 12),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: OrderaDesign.background, borderRadius: BorderRadius.circular(4)),
                        child: Text('${item.quantity}x', style: OrderaDesign.label.copyWith(fontSize: 10, color: OrderaDesign.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.product?.name ?? 'Item',
                          style: OrderaDesign.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${((item.product?.price ?? 0) * item.quantity).toStringAsFixed(2)}',
                        style: OrderaDesign.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Method', style: OrderaDesign.label),
                    Row(
                      children: [
                        Icon(
                          order.paymentMethod == 'upi' ? Icons.qr_code_scanner : 
                          order.paymentMethod == 'card' ? Icons.credit_card : Icons.payments,
                          size: 16, color: OrderaDesign.textSecondary
                        ),
                        const SizedBox(width: 6),
                        Text(order.paymentMethod.toUpperCase(), style: OrderaDesign.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Status', style: OrderaDesign.label),
                    Text(order.paymentStatus.toUpperCase(), style: OrderaDesign.bodyMedium.copyWith(
                      color: order.paymentStatus == 'paid' ? OrderaDesign.accent : OrderaDesign.warning,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
