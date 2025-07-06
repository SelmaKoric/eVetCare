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
    public class TreatmentController : BaseCRUDController<Treatment, TreatmentSearchObject, TreatmentInsertRequest, TreatmentUpdateRequest>
    {
        public TreatmentController(ITreatmentService service) : base(service)
        {
        }
    }
}

