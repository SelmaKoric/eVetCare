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
    public class PetsController : BaseCRUDController<Pets, PetsSearchObject, PetsInsertRequest, PetsUpdateRequest>
    {
        public PetsController(IPetsService service) : base(service)
        {
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override Pets Insert([FromForm] PetsInsertRequest request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override Pets Update(int id, [FromForm] PetsUpdateRequest request)
        {
            return _service.Update(id, request);
        }
    }
}

