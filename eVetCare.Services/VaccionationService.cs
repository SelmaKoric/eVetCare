using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
	public class VaccionationService : BaseCRUDService<Model.Vaccination, VaccinationSearchObject, Database.Vaccination, VaccinationInsertRequest, VaccinationUpdateRequest>, IVaccinationsService
    {
        public VaccionationService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.Vaccination> Filter(VaccinationSearchObject search, IQueryable<Database.Vaccination> query)
        {
            var queryFilter = base.Filter(search, query);

            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                queryFilter = queryFilter.Where(x => x.Name.Contains(search.Name));
            }

            if (search.DateGiven.HasValue)
            {
                queryFilter = queryFilter.Where(x => x.DateGiven.Date == search.DateGiven.Value.Date);
            }

            return queryFilter;
        }
    }
}

