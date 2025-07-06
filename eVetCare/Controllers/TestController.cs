using System;
using EasyNetQ;
using eVetCare.Model.Messaging;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TestController : ControllerBase
    {
        private readonly IBus _bus;

        public TestController(IBus bus)
        {
            _bus = bus;
        }

        [HttpPost("send-notification")]
        public async Task<IActionResult> SendTestNotification()
        {
            var message = new AppointmentNotificationMessage
            {
                OwnerEmail = "owner@example.com",
                Message = "Your appointment is tomorrow at 10:00 AM."
            };

            await _bus.PubSub.PublishAsync(message);
            return Ok("Notification sent to RabbitMQ.");
        }
    }
}

