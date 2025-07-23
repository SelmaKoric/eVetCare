using System;
namespace eVetCare.Model
{
	public class Pets
	{
        public int PetId { get; set; }

        public string OwnerName { get; set; }

        public string OwnerPhoneNumber { get; set; }

        public string OwnerEmail { get; set; }

        public string Name { get; set; } = null!;

        public string Species { get; set; }

        public string? Breed { get; set; }

        public string? GenderName { get; set; }

        public int? Age { get; set; }

        public double? Weight { get; set; }

        public string? PhotoUrl { get; set; }

    }
}

