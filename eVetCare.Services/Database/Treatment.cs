using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Treatment
{
    public int TreatmentId { get; set; }

    public int MedicalRecordId { get; set; }

    public string TreatmentDescription { get; set; } = null!;

    public virtual MedicalRecord MedicalRecord { get; set; } = null!;
}
