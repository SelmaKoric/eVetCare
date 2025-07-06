using System;
namespace eVetCare.Model.Requests
{
	public class PaymentInsertRequest
	{
        public int InvoiceId { get; set; }

        public decimal Amount { get; set; }

        public int MethodId { get; set; }  

        public DateTime PaymentDate { get; set; } = DateTime.Now;
    }
}

