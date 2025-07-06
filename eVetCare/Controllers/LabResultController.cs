using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class LabResultController : BaseCRUDController<LabResult, LabResultSearchObject, LabResultInsertRequest, LabResultUpdateRequest>
    {
        public LabResultController(ILabResultService service) : base(service)
        {
        }
    }
}

