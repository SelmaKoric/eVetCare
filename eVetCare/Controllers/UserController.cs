using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<User, BaseSearchObject, object, UserUpdateRequest>
    {
        public UserController(IUserService service) : base(service)
        {
        }

        [HttpPost]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override User Insert([FromBody] object request)
        {
            throw new NotImplementedException("Insert not supported.");
        }
    }
}

