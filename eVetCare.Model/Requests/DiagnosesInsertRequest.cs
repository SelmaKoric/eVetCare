using System;
namespace eVetCare.Model.Requests
{
	public class DiagnosesInsertRequest
	{
        public int MedicalRecordId { get; set; }

        public string Description { get; set; } = null!;
    }
}

