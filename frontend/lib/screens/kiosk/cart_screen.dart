import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_cart_provider.dart';
import '../../services/api_service.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.items.isEmpty) {
            return Center(child: Text('Cart is empty'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: item.product!.imageUrl != null && item.product!.imageUrl!.isNotEmpty
                            ? Image.network(
                                '${ApiService().baseUrl}${item.product!.imageUrl}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, _, __) => Icon(Icons.broken_image),
                              )
                            : Icon(Icons.fastfood),
                        title: Text(item.product!.name),
                        subtitle: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => cart.decrementQuantity(i),
                            ),
                            Text('${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => cart.incrementQuantity(i),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(item.product!.price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => cart.removeItem(i),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                margin: EdgeInsets.all(15),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 20)),
                      Spacer(),
                      Chip(
                        label: Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String? error = await cart.placeOrder();
                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red));
                          }
                        },
                        child: Text('PAY NOW'),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
