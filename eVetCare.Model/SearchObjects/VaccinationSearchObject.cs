using System;
namespace eVetCare.Model.SearchObjects
{
	public class VaccinationSearchObject : BaseSearchObject
	{
        public string? Name { get; set; } = null!;

        public DateTime? DateGiven { get; set; }
    }
}

