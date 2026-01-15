import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_cart_provider.dart';
import 'dart:async';

class PaymentProcessingScreen extends StatefulWidget {
  final String paymentMethod;
  final double amount;

  PaymentProcessingScreen({required this.paymentMethod, required this.amount});

  @override
  _PaymentProcessingScreenState createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod == 'cash') {
       // Cash is manual, but we can simulate a "Confirmed" step
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate network delay for Card/UPI
    await Future.delayed(Duration(seconds: 3));

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    String? error = await cartProvider.placeOrder(paymentMethod: widget.paymentMethod);

    if (error == null) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      
      // Auto close after success
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } else {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.paymentMethod.toUpperCase()} Payment'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isProcessing && !_isSuccess) ...[
                _buildPaymentUI(),
                SizedBox(height: 40),
                Text(
                  'Total Amount: \$${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      widget.paymentMethod == 'cash' ? 'CONFIRM ORDER' : 'I HAVE PAID',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ] else if (_isProcessing) ...[
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 20),
                Text('Processing your payment...', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              ] else if (_isSuccess) ...[
                Icon(Icons.check_circle, size: 100, color: Colors.green),
                SizedBox(height: 20),
                Text('Order Successful!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 10),
                Consumer<CartProvider>(
                  builder: (context, cart, _) => Text(
                    'Order Number: #${cart.lastPlacedOrder?.orderNumber ?? '...'}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ),
                SizedBox(height: 10),
                Text('Your order has been sent to the kitchen.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentUI() {
    switch (widget.paymentMethod) {
      case 'upi':
        return Column(
          children: [
            Text('Scan QR to Pay via UPI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: QrImageView(
                data: "upi://pay?pa=restaurant@bank&pn=OrderaRestaurant&am=${widget.amount}&cu=USD",
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, color: Colors.green, size: 18),
                SizedBox(width: 5),
                Text('Secure UPI Payment', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        );
      case 'card':
        return Column(
          children: [
            Icon(Icons.credit_card, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('Please Insert/Swipe your Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Use the card reader attached to the kiosk', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 30),
            // Simulated Swiper Animation Placeholder
            Container(
              width: 200,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Container(
                      width: 200 * value,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      case 'cash':
        return Column(
          children: [
            Icon(Icons.payments, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text('Pay Cash at Counter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Text(
              'Please proceed to the billing counter and show your Order ID to the cashier.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                'A Token will be generated after confirmation.',
                style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
              ),
            )
          ],
        );
      default:
        return Text('Select a payment method');
    }
  }
}
