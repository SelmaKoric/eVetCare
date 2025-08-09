using System;
namespace eVetCare.Model.SearchObjects
{
    public class PetsSearchObject : BaseSearchObject
    {
        public string? NameOrOwnerName { get; set; }
        public int? OwnerId { get; set; }
    }
}

