using System;
namespace eVetCare.Model.SearchObjects
{
	public class AppointmentSearchObject : BaseSearchObject
	{
        public string? OwnerName { get; set; } = null!;

        public int? PetId { get; set; }

        public DateTime? Date { get; set; }

        public string? PetName { get; set; }

        public int? AppointmentStatusId { get; set; }
    }
}

