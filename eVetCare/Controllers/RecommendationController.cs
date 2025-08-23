using System;
using eVetCare.Model;
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

        [HttpGet("recommendations/{petId}")]
        public ActionResult<RecommendationModel> Get(int petId)
        {
            var recommendation = _recommendationService.GetRecommendationsForPet(petId);
            if (recommendation is null)
                return NotFound();

            return Ok(recommendation);
        }

        [HttpPost("recommendations/{petId}")]
        public IActionResult Generate(int petId)
        {
            _recommendationService.GenerateRecommendationsForPet(petId);
            return Ok("Recommendations generated.");
        }
    }
}

