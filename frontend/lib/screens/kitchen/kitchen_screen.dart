import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../config/design_system.dart';

class KitchenScreen extends StatefulWidget {
  @override
  _KitchenScreenState createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
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
        title: Text('Kitchen Display', style: OrderaDesign.heading2),
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
          // Filter out completed orders from the main view if desired, but let's show all for now
          final activeOrders = orderData.orders.where((o) => o.status != 'completed' && o.status != 'cancelled').toList();
          
          if (activeOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: OrderaDesign.accent.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('All Caught Up!', style: OrderaDesign.heading2),
                  const SizedBox(height: 8),
                  Text('No active orders at the moment.', style: OrderaDesign.bodyMedium),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 4 : (MediaQuery.of(context).size.width > 900 ? 3 : 2),
              childAspectRatio: 0.75,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: activeOrders.length,
            itemBuilder: (ctx, i) => _OrderTicket(order: activeOrders[i]),
          );
        },
      ),
    );
  }
}

class _OrderTicket extends StatelessWidget {
  final Order order;
  const _OrderTicket({required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isReady = order.status == 'ready';
    final Color statusColor = isReady ? OrderaDesign.accent : OrderaDesign.warning;
    final timeStr = order.createdAt != null ? DateFormat('HH:mm').format(order.createdAt!) : '--:--';

    return Container(
      decoration: OrderaDesign.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: statusColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.orderNumber ?? order.id}', 
                        style: OrderaDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(timeStr, style: OrderaDesign.label),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isReady ? 'READY' : 'PREPARING',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 24, thickness: 0.5),
                itemBuilder: (ctx, i) {
                  final item = order.items[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: OrderaDesign.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${item.quantity}x', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product?.name ?? 'Item #${item.productId}', 
                                style: OrderaDesign.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: OrderaDesign.textPrimary)),
                            if (item.selectedModifiers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.selectedModifiers.entries.map((e) => '${e.key}: ${e.value}').join(', '),
                                  style: OrderaDesign.label.copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Hero(
              tag: 'btn_${order.id}',
              child: ElevatedButton(
                onPressed: () {
                  final token = Provider.of<AuthProvider>(context, listen: false).user?.token ?? "";
                  final nextStatus = isReady ? 'completed' : 'ready';
                  Provider.of<OrderProvider>(context, listen: false).updateStatus(order.id!, nextStatus, token);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady ? OrderaDesign.textSecondary : OrderaDesign.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Text(
                  isReady ? 'PAID & SERVED' : 'MARK AS READY', 
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
