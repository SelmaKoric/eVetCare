using System;
using eVetCare.Model;

namespace eVetCare.Services.Interfaces
{
	public interface IRecommendationService
	{
        void GenerateRecommendationsForPet(int petId);
        RecommendationModel? GetRecommendationsForPet(int petId);
    }
}

