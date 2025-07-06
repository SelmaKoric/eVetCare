using System;
using System.Collections.Generic;

namespace eVetCare.Model.Requests
{
	public class InvoiceInsertRequest
	{
        public int AppointmentId { get; set; }

        public List<int> ServiceIds { get; set; }

        public DateTime IssueDate { get; set; } = DateTime.Now;
    }
}

