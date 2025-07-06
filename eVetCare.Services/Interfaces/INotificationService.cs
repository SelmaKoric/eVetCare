using System;
using eVetCare.Model;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
	public interface INotificationService : IService<Notification, NotificationSearchObject>
    {
        bool MarkAsRead(int id);
        List<Model.Notification> GetUnreadNotifications(int userId);
    }
}

