using System;
namespace eVetCare.Model
{
	public class Payment
	{
        public int PaymentId { get; set; }

        public int InvoiceId { get; set; }

        public decimal Amount { get; set; }

        public int MethodId { get; set; }

        public string MethodName { get; set; } = null!;

        public DateTime PaymentDate { get; set; }
    }
}

