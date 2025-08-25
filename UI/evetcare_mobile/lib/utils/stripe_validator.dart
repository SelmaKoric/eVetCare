import '../core/stripe_config.dart';

class StripeValidator {
  static bool isValidPublishableKey(String key) {
    if (key.isEmpty) return false;

    if (!key.startsWith('pk_test_') && !key.startsWith('pk_live_')) {
      return false;
    }

    if (key.length < 100 || key.length > 120) {
      return false;
    }

    return true;
  }

  /// Gets a validation message for the current Stripe configuration
  static String getValidationMessage() {
    final key = StripeConfig.publishableKey;

    if (key.isEmpty) {
      return 'Stripe publishable key is empty. Please add your key to StripeConfig.';
    }

    if (!key.startsWith('pk_test_') && !key.startsWith('pk_live_')) {
      return 'Invalid Stripe publishable key format. Key must start with pk_test_ or pk_live_.';
    }

    if (key.length < 100 || key.length > 120) {
      return 'Stripe publishable key appears to be too short or too long. Please check your key.';
    }

    return 'Stripe configuration appears valid.';
  }

  static bool isTestMode() {
    return StripeConfig.publishableKey.startsWith('pk_test_');
  }

  static String getModeDescription() {
    return isTestMode() ? 'Test Mode' : 'Live Mode';
  }
}
