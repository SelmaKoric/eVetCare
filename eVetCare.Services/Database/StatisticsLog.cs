using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class StatisticsLog
{
    public int StatId { get; set; }

    public string? Metric { get; set; }

    public string? Value { get; set; }

    public DateTime? LoggedAt { get; set; }

    public bool IsActive { get; set; }
}
