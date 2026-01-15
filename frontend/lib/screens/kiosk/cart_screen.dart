import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_cart_provider.dart';
import '../../services/api_service.dart';
import '../../config/design_system.dart';
import 'payment_processing_screen.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderaDesign.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrderaDesign.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Your Cart', style: OrderaDesign.heading2),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: OrderaDesign.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: OrderaDesign.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Menu'),
                  )
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: OrderaDesign.cardDecoration,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.product!.imageUrl != null && item.product!.imageUrl!.isNotEmpty
                              ? Image.network(
                                  '${ApiService().baseUrl}${item.product!.imageUrl}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, _, __) => Container(color: OrderaDesign.background, padding: const EdgeInsets.all(8), child: const Icon(Icons.broken_image)),
                                )
                              : Container(color: OrderaDesign.background, padding: const EdgeInsets.all(8), child: const Icon(Icons.fastfood, color: Colors.grey)),
                        ),
                        title: Text(item.product!.name, style: OrderaDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              _QtyButton(icon: Icons.remove, onTap: () => cart.decrementQuantity(i)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text('${item.quantity}', style: OrderaDesign.bodyLarge),
                              ),
                              _QtyButton(icon: Icons.add, onTap: () => cart.incrementQuantity(i)),
                            ],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: OrderaDesign.danger, size: 20),
                              onPressed: () => cart.removeItem(i),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '\$${(item.product!.price * item.quantity).toStringAsFixed(2)}',
                              style: OrderaDesign.bodyLarge.copyWith(color: OrderaDesign.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: OrderaDesign.bodyLarge),
                        Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: OrderaDesign.heading2.copyWith(color: OrderaDesign.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: OrderaDesign.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showPaymentSelection(context, cart.totalAmount),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text(
                            'PROCEED TO CHECKOUT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showPaymentSelection(BuildContext context, double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          left: 32, right: 32, bottom: 32 + MediaQuery.of(ctx).viewInsets.bottom, top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Payment Method', style: OrderaDesign.heading2),
            const SizedBox(height: 8),
            Text('Choose how you would like to pay', style: OrderaDesign.bodyMedium),
            const SizedBox(height: 32),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PaymentOption(
                      icon: Icons.qr_code_scanner,
                      title: 'UPI Payment',
                      subtitle: 'Scan any UPI QR code',
                      color: OrderaDesign.accent,
                      onTap: () => _navigateToProcessing(context, 'upi', amount),
                    ),
                    const SizedBox(height: 16),
                    _PaymentOption(
                      icon: Icons.credit_card,
                      title: 'Card Payment',
                      subtitle: 'Swipe or Tap your card',
                      color: Colors.blue,
                      onTap: () => _navigateToProcessing(context, 'card', amount),
                    ),
                    const SizedBox(height: 16),
                    _PaymentOption(
                      icon: Icons.payments_outlined,
                      title: 'Cash',
                      subtitle: 'Pay at the counter',
                      color: Colors.orange,
                      onTap: () => _navigateToProcessing(context, 'cash', amount),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProcessing(BuildContext context, String method, double amount) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(paymentMethod: method, amount: amount),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: OrderaDesign.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: OrderaDesign.primary),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: OrderaDesign.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: OrderaDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: OrderaDesign.bodyMedium),
        trailing: const Icon(Icons.chevron_right, color: OrderaDesign.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
