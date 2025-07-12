using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Appointment
{
    public int AppointmentId { get; set; }

    public int PetId { get; set; }

    public DateTime Date { get; set; }

    public TimeSpan Time { get; set; }

    public int AppointmentStatusId { get; set; }

    public TimeSpan? Duration { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual ICollection<AppointmentService> AppointmentServices { get; set; } = new List<AppointmentService>();

    public virtual AppointmentStatus AppointmentStatus { get; set; } = null!;

    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    public virtual ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();

    public virtual Pet Pet { get; set; } = null!;
}
