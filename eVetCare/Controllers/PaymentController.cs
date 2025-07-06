using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PaymentController : BaseCRUDController<Payment, PaymentSearchObject, PaymentInsertRequest, object>
    {
        public PaymentController(IPaymentService service) : base(service)
        {
        }

        [HttpPost("create-intent/{invoiceId}")]
        public async Task<IActionResult> CreatePaymentIntent(int invoiceId)
        {
            var clientSecret = await (_service as IPaymentService).CreatePaymentIntentAsync(invoiceId);
            if (string.IsNullOrEmpty(clientSecret))
                return BadRequest("Unable to create payment intent.");

            return Ok(new { ClientSecret = clientSecret });
        }
    }
}

