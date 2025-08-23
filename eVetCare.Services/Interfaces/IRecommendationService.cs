using System;
using eVetCare.Model;

namespace eVetCare.Services.Interfaces
{
	public interface IRecommendationService
	{
        void GenerateRecommendationsForPet(int petId);
        // Returns latest (prefer active) recommendation for the pet, or null
        RecommendationModel? GetRecommendationsForPet(int petId);
    }
}

