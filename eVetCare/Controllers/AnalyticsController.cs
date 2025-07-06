using eVetCare.Model;
using eVetCare.Services;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class AnalyticsController : ControllerBase
{
    private readonly IAnalyticsService _analyticsService;

    public AnalyticsController(IAnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    [HttpGet("most-common-services")]
    public ActionResult<List<ServiceUsage>> GetMostCommonServices()
    {
        return _analyticsService.GetMostCommonServices();
    }

    [HttpGet("disease-frequency")]
    public ActionResult<List<DiseaseFrequency>> GetDiseaseFrequencies()
    {
        return _analyticsService.GetDiseaseFrequencies();
    }
}