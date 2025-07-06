using System;
namespace eVetCare.Model.Requests
{
	public class VaccinationInsertRequest
	{
        public int MedicalRecordId { get; set; }

        public string Name { get; set; } = null!;

        public DateTime DateGiven { get; set; }

        public DateTime? NextDue { get; set; }
    }
}

