using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;

namespace eVetCare.Services
{
	public class UserService : BaseCRUDService<Model.User, BaseSearchObject, Database.User, object, UserUpdateRequest>, IUserService
    {
        public UserService(EVetCareContext context, IMapper mapper) : base(context, mapper) { }

        public override void BeforeUpdate(UserUpdateRequest request, Database.User entity)
        {
            entity.FirstName = request.FirstName;
            entity.LastName = request.LastName;
            entity.Email = request.Email;
            entity.PhoneNumber = request.PhoneNumber;
            entity.Username = request.Username;
        }
    }
}

