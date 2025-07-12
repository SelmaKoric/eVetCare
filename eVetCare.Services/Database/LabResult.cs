using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class LabResult
{
    public int LabResultId { get; set; }

    public int MedicalRecordId { get; set; }

    public string? ResultValue { get; set; }

    public int? LabTestId { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual LabTest? LabTest { get; set; }

    public virtual MedicalRecord MedicalRecord { get; set; } = null!;
}
