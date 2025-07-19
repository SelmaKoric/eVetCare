using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class AppointmentService
{
    public int AppointmentServicesId { get; set; }

    public int AppointmentId { get; set; }

    public int ServiceId { get; set; }

    public bool IsActive { get; set; }

    public virtual Appointment Appointment { get; set; } = null!;

    public virtual Service Service { get; set; } = null!;
}
