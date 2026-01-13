import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

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
      appBar: AppBar(title: Text('Kitchen Display')),
      body: Consumer<OrderProvider>(
        builder: (ctx, orderData, _) {
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: orderData.orders.length,
            itemBuilder: (ctx, i) {
              final order = orderData.orders[i];
              // Filter out completed if desired, but for now show all
              return Card(
                color: order.status == 'ready' ? Colors.green[100] : order.status == 'completed' ? Colors.grey[200] : Colors.white,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.id}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(order.createdAt?.toLocal().toString().split('.')[0] ?? '', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Divider(),
                      ...order.items.map((item) => Text('${item.quantity}x ${item.product?.name ?? 'Product #${item.productId}'}', style: TextStyle(fontSize: 16))).toList(),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status: ${order.status.toUpperCase()}'),
                          if (order.status == 'pending')
                            ElevatedButton(
                              onPressed: () {
                                final token = Provider.of<AuthProvider>(context, listen: false).user?.token ?? "";
                                orderData.updateStatus(order.id!, 'ready', token);
                              },
                              child: Text('Mark Ready'),
                            )
                          else if (order.status == 'ready')
                            ElevatedButton(
                              onPressed: () {
                                final token = Provider.of<AuthProvider>(context, listen: false).user?.token ?? "";
                                orderData.updateStatus(order.id!, 'completed', token);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                              child: Text('Complete'),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
