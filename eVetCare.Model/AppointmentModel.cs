using System;
using System.Collections.Generic;

namespace eVetCare.Model
{
	public class Appointment
	{
        public int AppointmentId { get; set; }

        public int PetId { get; set; }

        public string PetName { get; set; } = null!;

        public string OwnerName { get; set; } = null!;

        public string Date { get; set; }

        public string Time { get; set; }

        public List<AppointmentService> ServiceNames { get; set; } 

        public string Status { get; set; } = null!;
    }
}

