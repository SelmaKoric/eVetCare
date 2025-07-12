using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Diagnosis
{
    public int DiagnosisId { get; set; }

    public int MedicalRecordId { get; set; }

    public string Description { get; set; } = null!;

    public bool? IsDeleted { get; set; }

    public virtual MedicalRecord MedicalRecord { get; set; } = null!;
}
