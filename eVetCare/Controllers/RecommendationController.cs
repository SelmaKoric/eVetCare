using System;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RecommendationController : ControllerBase
    {
        private readonly IRecommendationService _recommendationService;

        public RecommendationController(IRecommendationService recommendationService)
        {
            _recommendationService = recommendationService;
        }

        [HttpPost("recommendations/{petId}")]
        public IActionResult Generate(int petId)
        {
            _recommendationService.GenerateRecommendationsForPet(petId);
            return Ok("Recommendations generated.");
        }
    }
}

