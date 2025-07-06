using System;
using Azure.Core;
using eVetCare.Services.Database;
using Microsoft.AspNetCore.Mvc;
using Stripe;
using Stripe.Checkout;
using System.Text;

[ApiController]
[Route("webhook/stripe")]
public class StripeWebhookController : ControllerBase
{
    private readonly IConfiguration _config;
    private readonly EVetCareContext _context;

    public StripeWebhookController(IConfiguration config, EVetCareContext context)
    {
        _config = config;
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> Handle()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var signatureHeader = Request.Headers["Stripe-Signature"];
        var webhookSecret = _config["Stripe:WebhookSecret"];

        try
        {
            var stripeEvent = EventUtility.ConstructEvent(json, signatureHeader, webhookSecret);

            if (stripeEvent.Type == "payment_intent.succeeded")
            {
                var intent = stripeEvent.Data.Object as PaymentIntent;
                var invoiceId = int.Parse(intent.Metadata["invoiceId"]);

                var invoice = _context.Invoices.FirstOrDefault(i => i.InvoiceId == invoiceId);
                if (invoice != null)
                {
                    _context.Payments.Add(new Payment
                    {
                        InvoiceId = invoice.InvoiceId,
                        Amount = invoice.TotalAmount,
                        MethodId = 2, 
                        PaymentDate = DateTime.Now
                    });

                    await _context.SaveChangesAsync();
                }
            }

            return Ok();
        }
        catch (StripeException ex)
        {
            return BadRequest();
        }
    }
}