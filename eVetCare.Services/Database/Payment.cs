namespace eVetCare.Services.Database;

public partial class Payment
{
    public int PaymentId { get; set; }

    public int InvoiceId { get; set; }

    public decimal Amount { get; set; }

    public int MethodId { get; set; }

    public DateTime PaymentDate { get; set; }

    public bool? IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public virtual Invoice Invoice { get; set; } = null!;

    public virtual PaymentMethod Method { get; set; } = null!;
}
