using System;
namespace eVetCare.Model
{
	public class Notification
	{
        public int NotificationId { get; set; }

        public int UserId { get; set; }

        public string Message { get; set; }

        public DateTime? DateTimeSent { get; set; }

        public bool IsRead { get; set; } 

        public virtual User User { get; set; } = null!;

        public bool? IsDeleted { get; set; }

    }
}

