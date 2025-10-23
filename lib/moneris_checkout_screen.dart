import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Required for Android
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Required for iOS
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MonerisCheckoutScreen extends StatefulWidget {
  final String checkoutId;
  final String amount;
  final Function(Map<String, dynamic>) onPaymentComplete;
  final Function(String) onError;
  final Function() onCancelled;

  const MonerisCheckoutScreen({
    Key? key,
    required this.checkoutId,
    required this.amount,
    required this.onPaymentComplete,
    required this.onError,
    required this.onCancelled,
  }) : super(key: key);

  @override
  State<MonerisCheckoutScreen> createState() => _MonerisCheckoutScreenState();
}

class _MonerisCheckoutScreenState extends State<MonerisCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final platform = WebViewPlatform.instance;
    
    late final PlatformWebViewControllerCreationParams params;
    if (platform is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    
    // Enable JavaScript
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    
    // Platform-specific configurations
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }
    
    // Handle page loading states
    controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (String url) {
        setState(() {
          _isLoading = true;
        });
      },
      onPageFinished: (String url) {
        setState(() {
          _isLoading = false;
        });
      },
      onWebResourceError: (WebResourceError error) {
        widget.onError('WebView error: ${error.description}');
      },
      onNavigationRequest: (NavigationRequest request) {
        // Handle navigation requests
        if (request.url.contains('cancel')) {
          widget.onCancelled();
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
    );

    // Add JavaScript channel for communication with the WebView
    controller.addJavaScriptChannel(
      'MonerisCheckout',
      onMessageReceived: (JavaScriptMessage message) {
        _handleMessage(message.message);
      },
    );

    // Load the Moneris Checkout HTML
    final htmlContent = '''
      <!DOCTYPE html>
      <html style="height: 100%;">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
        <script src="https://gatewayt.moneris.com/chkt/js/chkt_v1.00.js"></script>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          html, body {
            width: 100%;
            height: 100%;
            overflow: hidden;
            position: fixed;
            top: 0;
            left: 0;
            -webkit-overflow-scrolling: touch;
          }
          #monerisCheckout {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: none;
            overflow: auto;
            -webkit-overflow-scrolling: touch;
          }
        </style>
      </head>
      <body>
        <div id="monerisCheckout"></div>
        <script>
          // Initialize Moneris Checkout
          var myCheckout = new monerisCheckout();
          
          // Set up callbacks
          myCheckout.setCallback("page_loaded", function() {
            MonerisCheckout.postMessage(JSON.stringify({
              event: 'page_loaded'
            }));
          });

          myCheckout.setCallback("cancel_transaction", function() {
            MonerisCheckout.postMessage(JSON.stringify({
              event: 'cancelled'
            }));
          });

          myCheckout.setCallback("error_event", function(error) {
            MonerisCheckout.postMessage(JSON.stringify({
              event: 'error',
              data: error
            }));
          });

          myCheckout.setCallback("payment_receipt", function(receipt) {
            MonerisCheckout.postMessage(JSON.stringify({
              event: 'payment_receipt',
              data: receipt
            }));
          });

          myCheckout.setCallback("payment_complete", function(response) {
            MonerisCheckout.postMessage(JSON.stringify({
              event: 'payment_complete',
              data: response
            }));
          });

          // Initialize the checkout
          myCheckout.setMode("qa"); // Change to "prod" for production
          myCheckout.setCheckoutDiv("monerisCheckout");

          // Initialize the checkout with the required parameters
          const config = {
            checkout_id: '${widget.checkoutId}',
            environment: 'qa', // Change to 'prod' for production
            action: 'preload',
            order_no: 'ORDER_' + Date.now(),
            cust_id: 'CUST_' + Math.floor(Math.random() * 10000),
            amount: '${widget.amount}',
            crypt_type: '7',
            store_id: 'store1' // Replace with your store ID
          };

          // Start the Moneris Checkout flow
          myCheckout.startCheckout(JSON.stringify(config));
        </script>
      </body>
      </html>
    ''';

    controller.loadHtmlString(htmlContent, baseUrl: 'https://gatewayt.moneris.com');
    
    // Platform-specific configurations
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  void _handleMessage(String message) {
    try {
      final data = json.decode(message);
      final event = data['event'];
      
      switch (event) {
        case 'page_loaded':
          debugPrint('Moneris Checkout page loaded');
          break;
          
        case 'cancelled':
          widget.onCancelled();
          break;
          
        case 'error':
          widget.onError('Payment error: ${data['data']}');
          break;
          
        case 'payment_receipt':
          debugPrint('Payment receipt: ${data['data']}');
          break;
          
        case 'payment_complete':
          final response = data['data'];
          if (response is Map) {
            widget.onPaymentComplete(Map<String, dynamic>.from(response));
          } else {
            widget.onPaymentComplete({'response': response});
          }
          break;
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
      widget.onError('Error processing payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onCancelled();
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onCancelled,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
