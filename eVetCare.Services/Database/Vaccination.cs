using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Vaccination
{
    public int VaccinationId { get; set; }

    public string Name { get; set; } = null!;

    public DateTime DateGiven { get; set; }

    public DateTime? NextDue { get; set; }

    public int MedicalRecordId { get; set; }

    public bool IsActive { get; set; }

    public virtual MedicalRecord MedicalRecord { get; set; } = null!;
}
