using Microsoft.AspNetCore.Http;

namespace eVetCare.Model.Requests
{
	public class PetsUpdateRequest
	{
        public int? Age { get; set; }

        public double? Weight { get; set; }

        public IFormFile? Photo { get; set; }
    }
}

