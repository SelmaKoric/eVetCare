using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Species
{
    public int SpeciesId { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Pet> Pets { get; } = new List<Pet>();
}
