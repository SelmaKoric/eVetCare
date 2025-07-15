using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class LabTest
{
    public int LabTestId { get; set; }

    public string Name { get; set; } = null!;

    public string? Unit { get; set; }

    public string? ReferenceRange { get; set; }

    public bool? IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<LabResult> LabResults { get; set; } = new List<LabResult>();
}
