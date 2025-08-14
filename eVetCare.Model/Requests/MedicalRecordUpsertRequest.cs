using System;
using System.Collections.Generic;
using System.Text;

namespace eVetCare.Model.Requests
{
    public class MedicalRecordUpsertRequest
    {
        public int PetId { get; set; }

        public int AppointmentId { get; set; }

        public DateTime Date { get; set; }

        public string? Notes { get; set; }

        public string? AnalysisProvided { get; set; }

    }
}
