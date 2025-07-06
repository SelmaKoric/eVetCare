using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class AppointmentStatus
{
    public int AppointmentStatusId { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Appointment> Appointments { get; } = new List<Appointment>();
}
