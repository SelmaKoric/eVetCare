using System;
using eVetCare.Model;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
	public class AnalyticsService : IAnalyticsService
	{
        private readonly EVetCareContext _context;

        public AnalyticsService(EVetCareContext context)
        {
            _context = context;
        }

        public List<ServiceUsage> GetMostCommonServices()
        {
            return _context.AppointmentServices
                .Include(a => a.Service)
                .GroupBy(a => a.Service.ServiceId)
                .Select(g => new ServiceUsage
                {
                    ServiceId = g.Key,
                    ServiceName = g.First().Service.Name,
                    UsageCount = g.Count()
                })
                .OrderByDescending(x => x.UsageCount)
                .ToList();
        }

        public List<DiseaseFrequency> GetDiseaseFrequencies()
        {
            return _context.Diagnoses
                .GroupBy(d => d.DiagnosisId)
                .Select(g => new DiseaseFrequency
                {
                    DiagnosisId = g.Key,
                    DiagnosisName = g.First().Description,
                    Occurrence = g.Count()
                })
                .OrderByDescending(x => x.Occurrence)
                .ToList();
        }

    }
}

