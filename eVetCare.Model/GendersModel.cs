using System;
namespace eVetCare.Model
{
    public class Gender
    {
        public int GenderId { get; set; }

        public string Name { get; set; } = string.Empty;

        public bool? IsDeleted { get; set; }

    }
}

