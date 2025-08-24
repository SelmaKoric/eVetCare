using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;

namespace eVetCare.Services
{
	public class PaymentService : BaseCRUDService<Model.Payment, PaymentSearchObject, Database.Payment, PaymentInsertRequest, object>, IPaymentService
    {
        private readonly IConfiguration _config;

        public PaymentService(EVetCareContext context, IMapper mapper, IConfiguration config) : base(context, mapper)
        {
            _config = config;
        }

        protected override void BeforeInsert(PaymentInsertRequest request, Payment entity)
        {
            var invoice = _context.Invoices.FirstOrDefault(i => i.InvoiceId == request.InvoiceId);

            if (invoice == null)
                throw new Exception("Invoice not found.");

            var method = _context.PaymentMethods.FirstOrDefault(m => m.MethodId == request.MethodId);

            if (method == null)
                throw new Exception("Invalid Payment Method.");

            entity.InvoiceId = request.InvoiceId;
            entity.Amount = request.Amount;
            entity.MethodId = request.MethodId;
            entity.PaymentDate = request.PaymentDate;
        }

        public async Task<string> CreatePaymentIntentAsync(int invoiceId)
        {
            var invoice = _context.Invoices
                .Include(i => i.InvoiceItems)
                .ThenInclude(ii => ii.Service)
                .FirstOrDefault(i => i.InvoiceId == invoiceId);

            if (invoice == null)
                throw new Exception("Invoice not found");

            var amount = (long)(invoice.TotalAmount * 100);

            var options = new PaymentIntentCreateOptions
            {
                Amount = amount,
                Currency = "usd",
                Metadata = new Dictionary<string, string>
            {
                { "invoiceId", invoice.InvoiceId.ToString() }
            }
            };

            var service = new PaymentIntentService();
            var intent = await service.CreateAsync(options);

            return intent.ClientSecret;
        }
    }
}

