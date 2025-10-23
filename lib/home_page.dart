import 'package:flutter/material.dart';
import 'moneris_checkout_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _startCheckout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MonerisCheckoutScreen(
          checkoutId: 'YOUR_CHECKOUT_ID', // Replace with your checkout ID
          amount: '1.00', // Example amount
          onPaymentComplete: (response) {
            // Handle successful payment
            debugPrint('Payment successful: $response');
            Navigator.of(context).pop();
            _showSuccessDialog(context);
          },
          onError: (error) {
            // Handle errors
            debugPrint('Payment error: $error');
            Navigator.of(context).pop();
            _showErrorDialog(context, error);
          },
          onCancelled: () {
            // Handle cancellation
            debugPrint('Payment cancelled');
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('Thank you for your purchase!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text('An error occurred: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moneris Checkout Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startCheckout(context),
          child: const Text('Start Checkout'),
        ),
      ),
    );
  }
}
