using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using System.Security.Cryptography;
using System.Text;

namespace eVetCare.Services
{
	public class UserService : BaseCRUDService<Model.User, BaseSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
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

        public override void BeforeInsert(UserInsertRequest insert, User entity)
        {
            var salt = GenerateSalt();
            entity.PasswordSalt = salt;
            entity.PasswordHash = GenerateHash(salt, insert.Password);
            entity.Username = insert.Username;

            if (_context.Users.Any(k => k.Username == insert.Username))
            {
                Console.WriteLine("User with this username already exists.");
            }
            else if (_context.Users.Any(k => k.Email == insert.Email))
            {
                Console.WriteLine("User with this email already exists.");
            }
            base.BeforeInsert(insert, entity);
        }
        public static string GenerateSalt()
        {
            return BCrypt.Net.BCrypt.GenerateSalt();
        }

        public static string GenerateHash(string salt, string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password, salt);
        }
    }
}

