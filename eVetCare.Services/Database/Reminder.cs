using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Reminder
{
    public int ReminderId { get; set; }

    public int UserId { get; set; }

    public string? Type { get; set; }

    public DateTime? TargetDate { get; set; }

    public virtual User User { get; set; } = null!;
}
