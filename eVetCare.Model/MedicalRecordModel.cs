using System;
using System.Collections.Generic;

namespace eVetCare.Model
{
	public class MedicalRecord
	{
        public int MedicalRecordId { get; set; }

        public int PetId { get; set; }

        public string PetName { get; set; } = null!;

        public int AppointmentId { get; set; }

        public DateTime Date { get; set; }

        public string? Notes { get; set; }

        public string? AnalysisProvided { get; set; }

        public List<Diagnoses> Diagnoses { get; set; }

        public List<Treatment> Treatments { get; set; }

        public List<LabResult> LabResults { get; set; }

        public List<Vaccination> Vaccinations { get; set; }

    }
}

