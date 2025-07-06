using System;
using Microsoft.AspNetCore.Http;

namespace eVetCare.Model.Requests
{
	public class PetsInsertRequest
	{
        public int? OwnerId { get; set; }

        public string OwnerFirstName { get; set; }

        public string OwnerLastName { get; set; }
        
        public string OwnerEmail { get; set; }

        public string OwnerPhoneNumber { get; set; }

        public string Name { get; set; } = null!;

        public int SpeciesId { get; set; }

        public string? Breed { get; set; }

        public int? GenderId { get; set; }

        public int? Age { get; set; }

        public double? Weight { get; set; }

        public IFormFile? Photo { get; set; }
    }
}

