using System;
using System.Collections.Generic;

namespace eVetCare.Model
{
	public class User
	{
        public int UserId { get; set; }

        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string Username { get; set; }

        public string PhoneNumber { get; set; }

        public bool IsActive { get; set; }

        public bool IsAppUser { get; set; }

        public virtual List<Pets> Pets { get; set; } 
    }
}

