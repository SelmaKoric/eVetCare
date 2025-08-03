using System;
using System.Collections.Generic;
using System.Text;

namespace eVetCare.Model.Requests
{
    public class UserInsertRequest
    {
        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string? Username { get; set; }

        public string? Password { get; set; }

        public string? PhoneNumber { get; set; }

    }
}
