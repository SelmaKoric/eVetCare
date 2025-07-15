namespace eVetCare.Services.Database;

public partial class Reminder
{
    public int ReminderId { get; set; }

    public int UserId { get; set; }

    public string? Type { get; set; }

    public DateTime? TargetDate { get; set; }

    public bool? IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public virtual User User { get; set; } = null!;
}
