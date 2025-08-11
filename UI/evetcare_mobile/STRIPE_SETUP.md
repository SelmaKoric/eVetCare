# Stripe Payment Setup for eVetCare Mobile

## Prerequisites

1. A Stripe account (sign up at https://stripe.com)
2. Your Stripe publishable key
3. Backend API endpoint that creates payment intents

## Setup Instructions

### 1. Configure Stripe Publishable Key

1. Go to your Stripe Dashboard
2. Navigate to Developers > API keys
3. Copy your **Publishable key** (starts with `pk_test_` for test mode or `pk_live_` for live mode)
4. Open `lib/core/stripe_config.dart`
5. Replace `'pk_test_your_publishable_key_here'` with your actual publishable key

```dart
static const String publishableKey = 'pk_test_your_actual_key_here';
```

### 2. Payment Sheet Features

The app now uses Stripe's Payment Sheet which provides:
- **Native UI**: Professional payment interface handled by Stripe
- **Security**: All payment data is processed securely through Stripe
- **Multiple Payment Methods**: Supports cards, Apple Pay, Google Pay, and more
- **Automatic Validation**: Built-in card validation and error handling
- **Localization**: Automatically adapts to user's language and region

### 3. Backend API Requirements

Your backend API endpoint `http://localhost:5081/Payment/create-intent/{invoiceId}` should:

1. Accept a POST request with the invoice ID in the URL path
2. Return a JSON response with the client secret:
```json
{
  "clientSecret": "pi_xxx_secret_xxx"
}
```

### 4. Backend Implementation Example (C#)

```csharp
[HttpPost("Payment/create-intent/{invoiceId}")]
public async Task<IActionResult> CreatePaymentIntent(int invoiceId)
{
    // Get invoice details from database
    var invoice = await _invoiceService.GetInvoiceById(invoiceId);
    
    if (invoice == null)
    {
        return NotFound("Invoice not found");
    }

    var options = new PaymentIntentCreateOptions
    {
        Amount = (long)(invoice.Amount * 100), // Convert to cents
        Currency = "usd",
        Metadata = new Dictionary<string, string>
        {
            { "invoiceId", invoiceId.ToString() }
        }
    };

    var service = new PaymentIntentService();
    var paymentIntent = await service.CreateAsync(options);

    return Ok(new { clientSecret = paymentIntent.ClientSecret });
}
```

### 5. Testing

1. Use Stripe's test card numbers for testing:
   - **Success**: `4242 4242 4242 4242`
   - **Decline**: `4000 0000 0000 0002`
   - **Requires Authentication**: `4000 0025 0000 3155`

2. Use any future expiry date (e.g., `12/25`)
3. Use any 3-digit CVV (e.g., `123`)

### 6. Production Deployment

Before going live:

1. Switch to live mode in your Stripe Dashboard
2. Update the publishable key to use `pk_live_` instead of `pk_test_`
3. Ensure your backend is using live mode API keys
4. Test with real cards in live mode

## Security Notes

- Never expose your Stripe secret key in the mobile app
- Always use the publishable key in the mobile app
- Handle payment confirmation on your backend
- Implement proper error handling and logging
- Follow PCI compliance guidelines

## Troubleshooting

### Common Issues

1. **"No such payment_intent" error**: Ensure your backend is creating payment intents correctly
2. **"Invalid publishable key" error**: Check that you're using the correct publishable key
3. **"Amount too small" error**: Ensure the amount is in cents (e.g., $50.00 = 5000 cents)

### Debug Mode

Enable debug logging by adding this to your main.dart:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Stripe debug mode
  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.instance.applySettings();
  
  runApp(const MyApp());
}
```

## Support

For Stripe-specific issues, refer to:
- [Stripe Documentation](https://stripe.com/docs)
- [Flutter Stripe Plugin](https://pub.dev/packages/flutter_stripe)
- [Stripe Support](https://support.stripe.com)
