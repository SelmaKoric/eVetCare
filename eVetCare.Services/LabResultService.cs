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
	public class LabResultService : BaseCRUDService<Model.LabResult, LabResultSearchObject, Database.LabResult, LabResultInsertRequest, LabResultUpdateRequest>, ILabResultService
    {
        public LabResultService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.LabResult> Filter(LabResultSearchObject search, IQueryable<Database.LabResult> query)
        {
            var queryFilter = base.Filter(search, query);

            queryFilter = queryFilter.Include(l => l.LabTest);

            if (!string.IsNullOrWhiteSpace(search.TestName))
            {
                queryFilter = queryFilter.Where(x => x.LabTest.Name.Contains(search.TestName));
            }

            return queryFilter;
        }

    }
}

