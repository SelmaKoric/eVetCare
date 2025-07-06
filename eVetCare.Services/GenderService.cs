using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;

namespace eVetCare.Services
{
	public class GenderService : BaseCRUDService<Model.Gender, GendersSearchObject, Database.Gender, GendersUpsertRequest, GendersUpsertRequest>, IGendersService
    {
        public GenderService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}

