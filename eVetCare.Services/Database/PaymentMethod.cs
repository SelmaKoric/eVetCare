namespace eVetCare.Services.Database;

public partial class PaymentMethod
{
    public int MethodId { get; set; }

    public string Name { get; set; } = null!;

    public bool? IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
