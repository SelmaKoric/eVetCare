using System;
namespace eVetCare.Model.Requests
{
	public class TreatmentInsertRequest
	{
        public int MedicalRecordId { get; set; }

        public string TreatmentDescription { get; set; } = null!;
    }
}

