using System;
namespace eVetCare.Model.Requests
{
	public class ServiceInsertRequest
	{
        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public int? CategoryId { get; set; }

        public decimal Price { get; set; }

        public int? DurationMinutes { get; set; }
    }
}

