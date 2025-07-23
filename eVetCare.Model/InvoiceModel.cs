using System;
using System.Collections.Generic;

namespace eVetCare.Model
{
	public class Invoice
	{
        public int InvoiceId { get; set; }

        public int AppointmentId { get; set; }

        public decimal TotalAmount { get; set; }

        public DateTime IssueDate { get; set; }

        public List<InvoiceItem> InvoiceItems { get; set; }

    }
}

