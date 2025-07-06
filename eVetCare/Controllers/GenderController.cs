using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;

namespace eVetCare.API.Controllers
{
	public class GenderController : BaseCRUDController<Model.Gender, GendersSearchObject, GendersUpsertRequest, GendersUpsertRequest>
    {
        public GenderController(IGendersService service) : base(service)
        {
        }
    }
}

