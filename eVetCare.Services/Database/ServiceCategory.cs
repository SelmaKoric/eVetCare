using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class ServiceCategory
{
    public int CategoryId { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Service> Services { get; } = new List<Service>();
}
