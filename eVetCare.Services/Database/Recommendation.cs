using System;
using System.Collections.Generic;

namespace eVetCare.Services.Database;

public partial class Recommendation
{
    public int RecommendationId { get; set; }

    public int PetId { get; set; }

    public string? Content { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Pet Pet { get; set; } = null!;
}
