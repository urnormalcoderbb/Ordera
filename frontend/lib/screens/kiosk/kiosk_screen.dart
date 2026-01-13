import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_cart_provider.dart';
import '../../services/api_service.dart';
import 'cart_screen.dart';

class KioskScreen extends StatefulWidget {
  @override
  _KioskScreenState createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MenuProvider>(context, listen: false).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order & Pay'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen())),
          ),
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(child: Text('${cart.items.length}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
          )
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (ctx, menu, _) {
          if (menu.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (menu.products.isEmpty) {
            return Center(child: Text('No menu items available.\nAsk manager to add products!'));
          }
          
          // Group products by category
          final grouped = <String, List>{};
          for (var p in menu.products) {
            final categoryName = p.categoryName ?? 'Other';
            grouped.putIfAbsent(categoryName, () => []).add(p);
          }
          
          return ListView(
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      entry.key,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (ctx, i) {
                      final product = entry.value[i];
                      return Card(
                        elevation: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.grey[200],
                                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        '${ApiService().baseUrl}${product.imageUrl}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (ctx, _, __) => Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      )
                                    : Center(child: Icon(Icons.fastfood, size: 50, color: Colors.grey)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('\$${product.price.toStringAsFixed(2)}'),
                                  SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: () {
                                      Provider.of<CartProvider>(context, listen: false).addToCart(product, 1, {});
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to cart!'), duration: Duration(milliseconds: 500)));
                                    },
                                    child: Text('Add'),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
