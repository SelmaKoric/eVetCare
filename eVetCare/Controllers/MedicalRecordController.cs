using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MedicalRecordController : BaseCRUDController<MedicalRecord, MedicalRecordSearchObject, MedicalRecordUpsertRequest, MedicalRecordUpsertRequest>
    {
        public MedicalRecordController(IMedicalRecordService service) : base(service)
        {
        }
    }
}

