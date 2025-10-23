# Moneris Checkout Flutter Integration

A Flutter plugin for integrating Moneris Checkout (MCO) into your Flutter applications. This implementation provides a seamless way to process payments using Moneris's hosted payment page.

## Features

- Easy integration with Moneris Checkout
- Support for both test and production environments
- Comprehensive error handling
- Loading states and user feedback
- Platform-specific optimizations for Android and iOS

## Prerequisites

- Flutter SDK (latest stable version)
- Moneris Merchant Account
- Checkout ID from Moneris Merchant Resource Center

## Installation

1. Add the required dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.7.0
  webview_flutter_android: ^4.0.0
  webview_flutter_wkwebview: ^3.10.0
```

2. Run `flutter pub get` to install the dependencies.

## Setup

### Android

Add the following permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

Add the following to your `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Usage

1. Import the package:

```dart
import 'package:your_package_name/moneris_checkout_screen.dart';
```

2. Initialize and show the Moneris Checkout:

```dart
MonerisCheckoutScreen(
  checkoutId: 'your_checkout_id', // Replace with your Moneris Checkout ID
  amount: '10.00', // Payment amount
  onPaymentComplete: (response) {
    // Handle successful payment
    print('Payment successful: $response');
    Navigator.of(context).pop();
  },
  onError: (error) {
    // Handle errors
    print('Payment error: $error');
    Navigator.of(context).pop();
  },
  onCancelled: () {
    // Handle cancellation
    print('Payment cancelled');
    Navigator.of(context).pop();
  },
)
```

## Configuration

### Environment Settings

By default, the integration uses the test environment. To switch to production:

1. In `moneris_checkout_screen.dart`, update:
   - Change `https://gatewayt.moneris.com` to `https://gateway.moneris.com`
   - Update `environment: 'qa'` to `environment: 'prod'`
   - Change `myCheckout.setMode("qa")` to `myCheckout.setMode("prod")`

### Customization

You can customize the following:
- **HTML/CSS**: Modify the `htmlContent` string in `moneris_checkout_screen.dart`
- **Request Parameters**: Update the `preloadRequest` map to include additional parameters required by your Moneris configuration

## Example

See the `home_page.dart` file for a complete example of how to implement the Moneris Checkout in your app.

## Testing

1. Use the test environment for development and testing
2. Test with test card numbers provided by Moneris
3. Monitor the debug console for any errors or messages

## Production Checklist

- [ ] Update to production URLs and settings
- [ ] Replace test credentials with production ones
- [ ] Implement proper error handling and user feedback
- [ ] Test thoroughly on both Android and iOS devices

## Support

For issues and feature requests, please file an issue on the GitHub repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Moneris Documentation](https://developer.moneris.com/)
- [Flutter WebView Plugin](https://pub.dev/packages/webview_flutter)
