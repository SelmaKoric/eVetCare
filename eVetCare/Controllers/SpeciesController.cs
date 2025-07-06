using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SpeciesController : BaseCRUDController<Model.Species, SpeciesSearchObject, SpeciesUpsertRequest, SpeciesUpsertRequest>
    {
        public SpeciesController(ISpeciesService service) : base(service)
        {
        }

    }
}

