using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;

namespace eVetCare.API.Controllers
{
        public class ServiceCategoryController : BaseCRUDController<ServiceCategoryModel, ServiceCategorySearchObject, ServiceCategoryInsertRequest, ServiceCategoryUpdateRequest>
        {
            public ServiceCategoryController(IServiceCategoryService service) : base(service)
            {
            }
        }
}
