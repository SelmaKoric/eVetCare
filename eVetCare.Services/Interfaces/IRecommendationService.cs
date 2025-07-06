using System;
namespace eVetCare.Services.Interfaces
{
	public interface IRecommendationService
	{
        void GenerateRecommendationsForPet(int petId);
    }
}

