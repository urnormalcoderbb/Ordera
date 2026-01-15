import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../models/models.dart';
import '../../providers/menu_cart_provider.dart';
import '../../services/api_service.dart';

class KioskScreen extends StatefulWidget {
  @override
  _KioskScreenState createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MenuProvider>(context, listen: false).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderaDesign.background,
      body: Row(
        children: [
          // Sidebar Category Navigation
          _buildSidebar(),
          
          // Main Menu Area
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildProductGrid()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Consumer<MenuProvider>(
      builder: (context, menu, _) {
        final categories = <String>{'All'};
        for (var p in menu.products) {
          categories.add(p.categoryName ?? 'Other');
        }

        return Container(
          width: 250,
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Menu', style: OrderaDesign.heading2),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final cat = categories.elementAt(i);
                    final isSelected = (_selectedCategory == null && cat == 'All') || _selectedCategory == cat;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? OrderaDesign.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? Icons.circle : Icons.circle_outlined,
                          size: 12,
                          color: isSelected ? OrderaDesign.primary : OrderaDesign.textSecondary,
                        ),
                        title: Text(
                          cat,
                          style: OrderaDesign.bodyLarge.copyWith(
                            color: isSelected ? OrderaDesign.primary : OrderaDesign.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        onTap: () => setState(() => _selectedCategory = cat == 'All' ? null : cat),
                      ),
                    );
                  },
                ),
              ),
              // Logo/Brand at bottom
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/role_selection'),
                      icon: const Icon(Icons.logout, size: 18, color: OrderaDesign.textSecondary),
                      label: Text('Switch Mode', style: OrderaDesign.label),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu, color: OrderaDesign.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Ordera', style: OrderaDesign.heading2.copyWith(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedCategory ?? 'All Items',
            style: OrderaDesign.heading2.copyWith(fontSize: 28),
          ),
          Consumer<CartProvider>(
            builder: (ctx, cart, _) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/cart'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: OrderaDesign.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: OrderaDesign.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Cart (${cart.items.length})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    const VerticalDivider(color: Colors.white70, width: 1),
                    const SizedBox(width: 12),
                    Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<MenuProvider>(
      builder: (ctx, menu, _) {
        if (menu.isLoading) return const Center(child: CircularProgressIndicator());
        
        final products = _selectedCategory == null 
            ? menu.products 
            : menu.products.where((p) => p.categoryName == _selectedCategory).toList();

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_meals_outlined, size: 80, color: OrderaDesign.textSecondary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No items in this category', style: OrderaDesign.bodyMedium),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: products.length,
          itemBuilder: (ctx, i) => _ProductItem(product: products[i]),
        );
      },
    );
  }
}

class _ProductItem extends StatefulWidget {
  final Product product;
  const _ProductItem({required this.product});

  @override
  State<_ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<_ProductItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovering ? 0.1 : 0.05),
              blurRadius: _isHovering ? 20 : 10,
              offset: Offset(0, _isHovering ? 10 : 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Hero(
                      tag: 'product_${widget.product.id}',
                      child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                          ? Image.network(
                              '${ApiService().baseUrl}${widget.product.imageUrl}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (ctx, _, __) => Container(
                                color: OrderaDesign.background,
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: OrderaDesign.background,
                              child: const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.grey)),
                            ),
                    ),
                  ),
                  if (widget.product.isAvailable == false)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: const Center(
                        child: Text(
                          'SOLD OUT',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: OrderaDesign.bodyLarge),
                  const SizedBox(height: 4),
                  Text('\$${widget.product.price.toStringAsFixed(2)}', 
                    style: OrderaDesign.bodyMedium.copyWith(color: OrderaDesign.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isHovering ? OrderaDesign.primary : OrderaDesign.background,
                        foregroundColor: _isHovering ? Colors.white : OrderaDesign.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addToCart(widget.product, 1, {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${widget.product.name} to cart!', style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: OrderaDesign.accent,
                            behavior: SnackBarBehavior.floating,
                            width: 300,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text('Add to Order', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
