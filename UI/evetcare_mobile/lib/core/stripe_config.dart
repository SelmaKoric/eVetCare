class StripeConfig {
  static const String publishableKey =
      'pk_test_51RZGrFCaBY5A2JTgpbvxhWoonXKLk2WMDBVBY8dk3hWoJqILYSzYb99094Iz5dsyCUW0Pos5fspCabSRgPYpXBxm009lG3GVtk';

  static const String apiUrl = 'http://10.0.2.2:5081';

  static const String currency = 'usd';
  static const int minAmount = 50; 
  static const int maxAmount = 1000000; 

  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidAmount = 'Invalid payment amount.';
  static const String paymentCanceled = 'Payment was canceled.';
  static const String paymentFailed = 'Payment failed. Please try again.';
  static const String invalidApiKey =
      'Invalid Stripe API key. Please check your configuration.';
}
