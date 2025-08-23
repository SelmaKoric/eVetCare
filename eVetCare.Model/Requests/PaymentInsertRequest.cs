using System;
namespace eVetCare.Model.Requests
{
	public class PaymentInsertRequest
	{
        public int InvoiceId { get; set; }

        public decimal Amount { get; set; }

        public int MethodId { get; set; }  

        public DateTime PaymentDate { get; set; } = DateTime.Now;

        public string? PaymentIntentId { get; set; }

        public string? PaymentMethodId { get; set; }

        public string? Status { get; set; }

        public string? CustomerName { get; set; }

        public string? CustomerZip { get; set; }

        public string? Metadata { get; set; }

        public string? Currency { get; set; }
    }
}

