using System;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using eVetCare.Model.Requests;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
	public class NotificationService : BaseCRUDService<Model.Notification, NotificationSearchObject, Database.Notification, NotificationUpsertRequest, NotificationUpsertRequest>, INotificationService
    {
		public NotificationService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {
		}

        public override IQueryable<Database.Notification> Filter(NotificationSearchObject search, IQueryable<Database.Notification> query)
        {
            var queryFilter = base.Filter(search, query);

            if (search.DateTimeSent.HasValue)
            {
                var date = search.DateTimeSent.Value.Date;
                queryFilter = queryFilter.Where(x => x.DateTimeSent.HasValue && x.DateTimeSent.Value.Date == date);
            }

            return queryFilter;
        }

        public bool MarkAsRead(int id)
        {
            var notification = _context.Notifications.FirstOrDefault(n => n.NotificationId == id);
            if (notification == null)
                return false;

            notification.IsRead = true;
            _context.SaveChanges();

            return true;
        }

        public List<Model.Notification> GetUnreadNotifications(int userId)
        {
            var notifications = _context.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .OrderByDescending(n => n.DateTimeSent)
                .ToList();

            return _mapper.Map<List<Model.Notification>>(notifications);
        }
    }
}

