using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
	public interface INotificationService : ICRUDService<Notification, NotificationSearchObject, NotificationUpsertRequest, NotificationUpsertRequest>
    {
        bool MarkAsRead(int id);
        List<Model.Notification> GetUnreadNotifications(int userId);
    }
}

