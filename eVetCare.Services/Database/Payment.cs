namespace eVetCare.Services.Database;

public partial class Payment
{
    public int PaymentId { get; set; }

    public int InvoiceId { get; set; }

    public decimal Amount { get; set; }

    public int MethodId { get; set; }

    public DateTime PaymentDate { get; set; }

    public bool IsActive { get; set; }

    public string? PaymentIntentId { get; set; }

    public string? PaymentMethodId { get; set; }

    public string? Status { get; set; }

    public string? CustomerName { get; set; }

    public string? CustomerZip { get; set; }

    public string? Metadata { get; set; }

    public string? Currency { get; set; }

    public virtual Invoice Invoice { get; set; } = null!;

    public virtual PaymentMethod Method { get; set; } = null!;
}
