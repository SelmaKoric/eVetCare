using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NotificationController : BaseCRUDController<Notification, NotificationSearchObject, NotificationUpsertRequest, NotificationUpsertRequest>
	{
        public NotificationController(INotificationService service) : base(service)
        {
        }

        [HttpPut("{id}/mark-as-read")]
        public IActionResult MarkAsRead(int id)
        {
            var result = (_service as INotificationService)?.MarkAsRead(id);

            if (result == null || result == false)
                return NotFound();

            return Ok("Notification marked as read.");
        }

        [HttpGet("user/{userId}/unread")]
        public IActionResult GetUnreadNotifications(int userId)
        {
            var result = (_service as INotificationService)?.GetUnreadNotifications(userId);

            if (result == null || result.Count == 0)
                return NotFound("No unread notifications found.");

            return Ok(result);
        }

    }
}

