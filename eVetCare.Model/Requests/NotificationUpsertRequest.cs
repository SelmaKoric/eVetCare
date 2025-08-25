using System;
using System.Collections.Generic;
using System.Text;

namespace eVetCare.Model.Requests
{
    public class NotificationUpsertRequest
    {
        public int UserId { get; set; }

        public string Message { get; set; } = null!;

    }
}
