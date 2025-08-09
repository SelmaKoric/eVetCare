using System;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace eVetCare.Services
{
    public class AuthService : IAuthService
    {
        private readonly EVetCareContext _context;
        private readonly IConfiguration _config;

        public AuthService(EVetCareContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        public LoginResponse Authenticate(LoginRequest request)
        {
            var user = _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefault(u => u.Username == request.Username);

            if (user == null || string.IsNullOrEmpty(user.PasswordHash) || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                throw new UnauthorizedAccessException("Invalid credentials.");

            var role = user.UserRoles.FirstOrDefault()?.Role?.RoleName ?? "User";

            var token = GenerateJwtToken(user, role);
            
            return new LoginResponse
            {
                Token = token,
                UserId = user.UserId,
                FullName = $"{user.FirstName} {user.LastName}",
                Role = role
            };

        }

        public string GenerateJwtToken(Database.User user, string role)
        {
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, role)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddHours(1),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}