using System;
using eVetCare.Model;

namespace eVetCare.Services.Interfaces
{
	public interface IAnalyticsService
	{
        List<ServiceUsage> GetMostCommonServices();
        List<DiseaseFrequency> GetDiseaseFrequencies();
    }
}

