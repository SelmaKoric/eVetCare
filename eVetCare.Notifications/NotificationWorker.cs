using EasyNetQ;
using eVetCare.Model.Messaging;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Notifications;

public class NotificationWorker : BackgroundService
{
    private readonly IBus _bus;
    private readonly IServiceScopeFactory _scopeFactory;

    public NotificationWorker(IBus bus, IServiceScopeFactory scopeFactory)
    {
        _bus = bus;
        _scopeFactory = scopeFactory;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _ = _bus.PubSub.SubscribeAsync<AppointmentNotificationMessage>("notification_subscription", async msg =>
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<EVetCareContext>();

            var user = await db.Users.FirstOrDefaultAsync(u => u.Email == msg.OwnerEmail);

            if (user != null)
            {
                var notification = new Notification
                {
                    UserId = user.UserId,
                    Message = msg.Message,
                    DateTimeSent = DateTime.Now
                };

                db.Notifications.Add(notification);
                await db.SaveChangesAsync();
            }
            else
            {
                Console.WriteLine($"User with email {msg.OwnerEmail} not found.");
            }

        }, cancellationToken: stoppingToken);

        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<EVetCareContext>();

            var targetTime = DateTime.Now.AddMinutes(1);
            var appointments = context.Appointments
                .Include(a => a.Pet).ThenInclude(p => p.Owner)
                .Where(a => a.Date == targetTime.Date && a.Time.Hours == targetTime.Hour && a.Time.Minutes == targetTime.Minute)
                .ToList();

            foreach (var appointment in appointments)
            {
                var message = new AppointmentNotificationMessage
                {
                    UserId = appointment.Pet.Owner.UserId,
                    OwnerEmail = appointment.Pet.Owner.Email,
                    Message = $"Reminder: Your appointment for {appointment.Pet.Name} is on {appointment.Date:dd.MM.yyyy} at {appointment.Time}."
                };

                await _bus.PubSub.PublishAsync(message);
            }

            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }
}
