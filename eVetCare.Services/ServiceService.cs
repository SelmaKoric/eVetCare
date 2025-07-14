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
	public class ServiceService : BaseCRUDService<Model.Service, ServiceSearchObject, Database.Service, ServiceInsertRequest, ServiceUpdateRequest>, IServiceService
    {
        public ServiceService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.Service> Filter(ServiceSearchObject search, IQueryable<Database.Service> query)
        {
            var queryFilter = base.Filter(search, query);

            queryFilter = query.Include(x => x.Category).AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                queryFilter = queryFilter.Where(x => x.Name.Contains(search.Name));
            }

            if (!string.IsNullOrWhiteSpace(search.CategoryName))
            {
                queryFilter = queryFilter.Where(x => x.Category.Name.Contains(search.CategoryName));
            }


            if (search.isDeleted!=null)
            {
                queryFilter = queryFilter.Where(x => x.IsDeleted == search.isDeleted);
            }

            return queryFilter;
        }

        public override void BeforeUpdate(ServiceUpdateRequest request, Database.Service entity)
        {
            if (request.CategoryId == 0)
                entity.CategoryId = null;

        }
    }
}

