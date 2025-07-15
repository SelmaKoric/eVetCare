using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Species
{
    public int SpeciesId { get; set; }

    public string Name { get; set; } = null!;

    public bool? IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<Pet> Pets { get; set; } = new List<Pet>();
}
