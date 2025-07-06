using System;
namespace eVetCare.Model
{
	public class Vaccination
	{
        public int VaccinationId { get; set; }

        public string Name { get; set; } = null!;

        public DateTime DateGiven { get; set; }

        public DateTime? NextDue { get; set; }
    }
}

