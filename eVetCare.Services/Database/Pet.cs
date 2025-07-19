using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Pet
{
    public int PetId { get; set; }

    public int OwnerId { get; set; }

    public string Name { get; set; } = null!;

    public int SpeciesId { get; set; }

    public string? Breed { get; set; }

    public int? Age { get; set; }

    public double? Weight { get; set; }

    public string? PhotoUrl { get; set; }

    public int? GenderId { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();

    public virtual Gender? Gender { get; set; }

    public virtual ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();

    public virtual User Owner { get; set; } = null!;

    public virtual ICollection<Recommendation> Recommendations { get; set; } = new List<Recommendation>();

    public virtual Species Species { get; set; } = null!;
}
