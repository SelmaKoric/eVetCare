using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Invoice
{
    public int InvoiceId { get; set; }

    public int AppointmentId { get; set; }

    public decimal TotalAmount { get; set; }

    public DateTime IssueDate { get; set; }

    public virtual Appointment Appointment { get; set; } = null!;

    public virtual ICollection<InvoiceItem> InvoiceItems { get; } = new List<InvoiceItem>();

    public virtual ICollection<Payment> Payments { get; } = new List<Payment>();
}
