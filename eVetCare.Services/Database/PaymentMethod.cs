using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class PaymentMethod
{
    public int MethodId { get; set; }

    public string Name { get; set; } = null!;

    public bool IsActive { get; set; }

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
