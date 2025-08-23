# Stripe Setup Guide for eVetCare Mobile

## Current Issue: Invalid API Key

You're getting an "invalid API key" error because the Stripe publishable key in your configuration is not valid.

## How to Fix This

### 1. Get Your Stripe Publishable Key

1. **Go to your Stripe Dashboard**: https://dashboard.stripe.com/
2. **Navigate to Developers → API keys**
3. **Copy your Publishable key** (starts with `pk_test_` for test mode or `pk_live_` for live mode)

### 2. Update Your Configuration

Open `lib/core/stripe_config.dart` and replace the `publishableKey` value:

```dart
static const String publishableKey = 'YOUR_ACTUAL_STRIPE_PUBLISHABLE_KEY_HERE';
```

### 3. Key Format Requirements

- **Test keys** start with: `pk_test_`
- **Live keys** start with: `pk_live_`
- Keys are typically 107 characters long
- Never share your secret key (starts with `sk_`)

### 4. Test Your Configuration

After updating the key:

1. **Restart your Flutter app**
2. **Check the console output** - you should see:
   ```
   Stripe initialized successfully with key: pk_test_51...
   Mode: Test Mode
   Validation: Stripe configuration appears valid.
   ```

### 5. Test Payment Flow

Use these test card numbers:
- **Success**: `4242 4242 4242 4242`
- **Decline**: `4000 0000 0000 0002`
- **Requires authentication**: `4000 0025 0000 3155`

## Common Issues

### Issue: "Invalid API key" error
**Solution**: Make sure you're using the publishable key (starts with `pk_`) not the secret key (starts with `sk_`)

### Issue: Key format error
**Solution**: Ensure the key starts with `pk_test_` or `pk_live_` and is the correct length

### Issue: Network error
**Solution**: Check that your backend server is running on `http://10.0.2.2:5081`

## Backend Requirements

Make sure your backend has:
1. **Stripe secret key** configured
2. **Payment endpoint** at `/Payment/create-intent/{invoiceId}`
3. **CORS** properly configured for mobile requests

## Security Notes

- ✅ **Safe to include in mobile app**: Publishable keys
- ❌ **Never include in mobile app**: Secret keys
- ✅ **Use test keys** for development
- ✅ **Use live keys** only for production

## Need Help?

If you're still having issues:
1. Check the console output for validation messages
2. Verify your Stripe account is active
3. Ensure your backend is properly configured with Stripe
4. Test with the provided test card numbers
