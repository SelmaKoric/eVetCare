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
    public class DiagnosesController : BaseCRUDController<Diagnoses, DiagnosesSearchObject, DiagnosesInsertRequest, DiagnosesUpdateRequest>
    {
        public DiagnosesController(IDiagnosesService service) : base(service)
        {
        }
    }
}

