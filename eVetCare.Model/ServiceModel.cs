using System;
using System.Collections.Generic;

namespace eVetCare.Model
{
	public class Service
	{
        public int ServiceId { get; set; }

        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public int? CategoryId { get; set; }

        public string? CategoryName { get; set; }

        public decimal? Price { get; set; }

        public int? DurationMinutes { get; set; }

    }
}

