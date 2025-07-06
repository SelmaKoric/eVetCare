using System;
namespace eVetCare.Model.Messaging
{
	public class AppointmentNotificationMessage
	{
            public int AppointmentId { get; set; }

            public string PetName { get; set; } = string.Empty;

            public int UserId { get; set; } 

            public string OwnerEmail { get; set; } = string.Empty;

            public DateTime AppointmentDateTime { get; set; }

            public string Message { get; set; } = string.Empty;

    }
}

