using System;
namespace eVetCare.Model.Requests
{
	public class LabResultInsertRequest
	{
        public int MedicalRecordId { get; set; }

        public int LabTestId { get; set; }

        public string? ResultValue { get; set; }
    }
}

