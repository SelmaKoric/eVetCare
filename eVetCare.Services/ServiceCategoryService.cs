using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;

namespace eVetCare.Services
{
    public class ServiceCategoryService : BaseCRUDService<ServiceCategoryModel, ServiceCategorySearchObject, Database.ServiceCategory, ServiceCategoryInsertRequest, ServiceCategoryUpdateRequest>, IServiceCategoryService
    {
        public ServiceCategoryService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
