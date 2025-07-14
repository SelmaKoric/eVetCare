using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
 
    public interface IServiceCategoryService : ICRUDService<ServiceCategoryModel, ServiceCategorySearchObject, ServiceCategoryInsertRequest, ServiceCategoryUpdateRequest>
    {

    }
}
