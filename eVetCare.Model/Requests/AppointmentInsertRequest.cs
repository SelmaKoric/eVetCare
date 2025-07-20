using System;
using System.Collections.Generic;

namespace eVetCare.Model.Requests
{
	public class AppointmentInsertRequest
	{
        public int PetId { get; set; }

        public DateTime Date { get; set; }

        public TimeSpan Time { get; set; }

        public TimeSpan? Duration { get; set; }

        public List<int> ServiceIds { get; set; }

        public int? AppointmentStatus { get; set; }

        public bool CreatedByAdmin { get; set; }
    }
}

