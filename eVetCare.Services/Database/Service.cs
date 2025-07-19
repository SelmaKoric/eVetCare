using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Service
{
    public int ServiceId { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public int? CategoryId { get; set; }

    public decimal? Price { get; set; }

    public int? DurationMinutes { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<AppointmentService> AppointmentServices { get; set; } = new List<AppointmentService>();

    public virtual ServiceCategory? Category { get; set; }

    public virtual ICollection<InvoiceItem> InvoiceItems { get; set; } = new List<InvoiceItem>();
}
