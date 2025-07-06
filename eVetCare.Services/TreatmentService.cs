using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
	public class TreatmentService : BaseCRUDService<Model.Treatment, TreatmentSearchObject, Database.Treatment, TreatmentInsertRequest, TreatmentUpdateRequest>, ITreatmentService
    {
        public TreatmentService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.Treatment> Filter(TreatmentSearchObject search, IQueryable<Database.Treatment> query)
        {
            var queryFilter = base.Filter(search, query);

            if (!string.IsNullOrWhiteSpace(search.TreatmentDescription))
            {
                queryFilter = queryFilter.Where(x => x.TreatmentDescription.Contains(search.TreatmentDescription));
            }

            return queryFilter;
        }
    }
}

