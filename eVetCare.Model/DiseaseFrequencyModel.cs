using System;
namespace eVetCare.Model
{
	public class DiseaseFrequency
	{
        public int DiagnosisId { get; set; }
        public string DiagnosisName { get; set; }
        public int Occurrence { get; set; }

        public bool? IsDeleted { get; set; }

    }
}

