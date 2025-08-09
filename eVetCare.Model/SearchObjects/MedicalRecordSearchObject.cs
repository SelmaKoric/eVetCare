using System;
namespace eVetCare.Model.SearchObjects
{
	public class MedicalRecordSearchObject : BaseSearchObject
	{
        public string? PetName { get; set; }

        public int? PetId { get; set; }

        public int? AppointmentId { get; set; }

        public DateTime? Date { get; set; }

        public string? DiagnosisKeyword { get; set; }

        public string? TreatmentKeyword { get; set; }

        public bool? IncludeDiagnoses { get; set; }

        public bool? IncludeTreatments { get; set; }

        public bool? IncludeLabResults { get; set; }

        public bool? IncludeVaccinations { get; set; }

    }
}

