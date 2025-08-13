using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;

namespace eVetCare.Services
{
    public class LabTestService : BaseCRUDService<Model.LabTestModel, LabTestSearchObject, LabTest, LabTestUpsertRequest, LabTestUpsertRequest>, ILabTest
    {
        public LabTestService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }
    }
}
