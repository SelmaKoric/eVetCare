using System;
namespace eVetCare.Model.SearchObjects
{
	public class ServiceSearchObject : BaseSearchObject
	{
        public string? Name { get; set; } = null!;

        public string? CategoryName { get; set; }
        public Boolean? isDeleted { get; set; }
    }
}

