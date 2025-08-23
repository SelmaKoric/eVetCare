class StripeConfig {
  // Replace this with your actual Stripe publishable key from your Stripe dashboard
  // This is a test key format - you need to replace it with your real test key
  static const String publishableKey =
      'pk_test_51RZGrFCaBY5A2JTgpbvxhWoonXKLk2WMDBVBY8dk3hWoJqILYSzYb99094Iz5dsyCUW0Pos5fspCabSRgPYpXBxm009lG3GVtk';

  // Stripe API configuration
  static const String apiUrl = 'http://10.0.2.2:5081';

  // Payment configuration
  static const String currency = 'usd';
  static const int minAmount = 50; // Minimum amount in cents ($0.50)
  static const int maxAmount = 1000000; // Maximum amount in cents ($10,000)

  // Error messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidAmount = 'Invalid payment amount.';
  static const String paymentCanceled = 'Payment was canceled.';
  static const String paymentFailed = 'Payment failed. Please try again.';
  static const String invalidApiKey =
      'Invalid Stripe API key. Please check your configuration.';
}
