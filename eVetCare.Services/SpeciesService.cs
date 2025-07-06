using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;

namespace eVetCare.Services
{
	public class SpeciesService : BaseCRUDService<Model.Species, SpeciesSearchObject, Database.Species, SpeciesUpsertRequest, SpeciesUpsertRequest>, ISpeciesService
    {
        public SpeciesService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}

