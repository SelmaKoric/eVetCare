using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class InvoiceItem
{
    public int InvoiceItemId { get; set; }

    public int InvoiceId { get; set; }

    public int ServiceId { get; set; }

    public bool? IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public virtual Invoice Invoice { get; set; } = null!;

    public virtual Service Service { get; set; } = null!;
}
