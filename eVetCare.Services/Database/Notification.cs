using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Notification
{
    public int NotificationId { get; set; }

    public int UserId { get; set; }

    public string Message { get; set; } = null!;

    public DateTime? DateTimeSent { get; set; }

    public bool IsRead { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual User User { get; set; } = null!;
}
