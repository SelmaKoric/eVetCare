using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class User
{
    public int UserId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? Username { get; set; }

    public string? PasswordHash { get; set; }

    public string? PasswordSalt { get; set; }

    public string? PhoneNumber { get; set; }

    public bool? IsActive { get; set; }

    public bool IsAppUser { get; set; }

    public virtual ICollection<Notification> Notifications { get; } = new List<Notification>();

    public virtual ICollection<Pet> Pets { get; } = new List<Pet>();

    public virtual ICollection<Reminder> Reminders { get; } = new List<Reminder>();

    public virtual ICollection<UserRole> UserRoles { get; } = new List<UserRole>();
}
