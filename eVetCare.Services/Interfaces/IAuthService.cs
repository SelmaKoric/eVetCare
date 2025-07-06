using System;
using eVetCare.Model;
using eVetCare.Model.Requests;

namespace eVetCare.Services.Interfaces
{
	public interface IAuthService
	{
        LoginResponse Authenticate(LoginRequest request);
        string GenerateJwtToken(Database.User user, string role);
    }
}

