using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class LabTestController : BaseCRUDController<LabTestModel, LabTestSearchObject, LabTestUpsertRequest, LabTestUpsertRequest>
    {
        public LabTestController(ILabTest service) : base(service)
        {
        }
    }
}
