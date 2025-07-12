using System;
namespace eVetCare.Model
{
	public class InvoiceItem
	{
        public int InvoiceItemId { get; set; }

        public int ServiceId { get; set; }

        public bool? IsDeleted { get; set; }


    }
}

