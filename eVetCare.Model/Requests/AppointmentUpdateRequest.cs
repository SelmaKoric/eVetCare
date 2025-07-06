using System;
using System.Collections.Generic;

namespace eVetCare.Model.Requests
{
	public class AppointmentUpdateRequest
	{
        public DateTime? Date { get; set; }

        public TimeSpan? Time { get; set; }

        public List<int> ServiceIds { get; set; }

        public int? AppointmentStatusId { get; set; }
    }
}

