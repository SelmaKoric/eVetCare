using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
	public class DiagnosesService : BaseCRUDService<Model.Diagnoses, DiagnosesSearchObject, Database.Diagnosis, DiagnosesInsertRequest, DiagnosesUpdateRequest>, IDiagnosesService
    {
        public DiagnosesService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Diagnosis> Filter(DiagnosesSearchObject search, IQueryable<Diagnosis> query)
        {
            var queryFilter = base.Filter(search, query);

            queryFilter = query.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.Description))
            {
                queryFilter = queryFilter.Where(x => x.Description.Contains(search.Description));
            }

            return queryFilter;
        }

    }
}

