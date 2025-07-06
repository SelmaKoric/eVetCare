using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class MedicalRecord
{
    public int MedicalRecordId { get; set; }

    public int PetId { get; set; }

    public int AppointmentId { get; set; }

    public DateTime Date { get; set; }

    public string? Notes { get; set; }

    public string? AnalysisProvided { get; set; }

    public virtual Appointment Appointment { get; set; } = null!;

    public virtual ICollection<Diagnosis> Diagnoses { get; } = new List<Diagnosis>();

    public virtual ICollection<LabResult> LabResults { get; } = new List<LabResult>();

    public virtual Pet Pet { get; set; } = null!;

    public virtual ICollection<Treatment> Treatments { get; } = new List<Treatment>();

    public virtual ICollection<Vaccination> Vaccinations { get; } = new List<Vaccination>();
}
