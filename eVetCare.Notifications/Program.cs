using eVetCare.Notifications;

IHost host = Host.CreateDefaultBuilder(args)
    .ConfigureServices(services =>
    {
        services.AddHostedService<NotificationWorker>();
    })
    .Build();

host.Run();
