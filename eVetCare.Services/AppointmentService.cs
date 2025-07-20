using EasyNetQ;
using eVetCare.Model.Enums;
using eVetCare.Model.Messaging;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Exceptions;
using eVetCare.Services.Helpers;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;

namespace eVetCare.Services
{
    public class AppointmentService : BaseCRUDService<Model.Appointment, AppointmentSearchObject, Database.Appointment, AppointmentInsertRequest, AppointmentUpdateRequest>, IAppointmentService
    {
        private readonly IBus _bus;

        public AppointmentService(EVetCareContext context, IMapper mapper, IBus bus) : base(context, mapper)
        {
            _bus = bus;
        }

        public override IQueryable<Database.Appointment> Filter(AppointmentSearchObject search, IQueryable<Database.Appointment> query)
        {
            var queryFilter = base.Filter(search, query);

            queryFilter = queryFilter.Include(a => a.Pet)
                                     .ThenInclude(p => p.Owner)
                                     .Include(a => a.AppointmentStatus)
                                     .Include(a => a.AppointmentServices)
                                     .ThenInclude(asv => asv.Service);

            if (!string.IsNullOrWhiteSpace(search.OwnerName))
            {
                var ownerName = search.OwnerName.ToLower();
                queryFilter = queryFilter.Where(x =>
                    (x.Pet.Owner.FirstName + " " + x.Pet.Owner.LastName).ToLower().Contains(ownerName));
            }

            if (!string.IsNullOrWhiteSpace(search.PetName))
            {
                queryFilter = queryFilter.Where(x => x.Pet.Name.ToLower().Contains(search.PetName.ToLower()));
            }

            if (search.PetId.HasValue)
            {
                queryFilter = queryFilter.Where(x => x.Pet.PetId == search.PetId.Value);
            }

            if (search.Date.HasValue)
            {
                queryFilter = queryFilter.Where(x => x.Date.Date == search.Date.Value.Date);
            }

            if (search.AppointmentStatusId.HasValue)
            {
                queryFilter.Where(x => x.AppointmentStatusId == search.AppointmentStatusId.Value);
            }

            return queryFilter;
        }

        public override void BeforeInsert(AppointmentInsertRequest request, Appointment entity)
        {
            var newStart = RoundToMinute(request.Date.Date + request.Time);
            var newEnd = newStart + (request.Duration ?? TimeSpan.FromMinutes(30));

            var sameDayAppointments = _context.Appointments
                .Where(a => a.Date.Date == request.Date.Date)
                .ToList();

            foreach (var a in sameDayAppointments)
            {
                var existingStart = RoundToMinute(a.Date.Date + a.Time);
                var existingEnd = existingStart + (a.Duration ?? TimeSpan.FromMinutes(30));

                var roundedNewStart = RoundToMinute(newStart);
                var roundedNewEnd = RoundToMinute(newEnd);

                Console.WriteLine($"existingStart: {existingStart:yyyy-MM-dd HH:mm}, existingEnd: {existingEnd:yyyy-MM-dd HH:mm}, newStart: {roundedNewStart:yyyy-MM-dd HH:mm}, newEnd: {roundedNewEnd:yyyy-MM-dd HH:mm}");

                if (existingStart < roundedNewEnd && existingEnd > roundedNewStart)
                {
                    throw new AppointmentOverlapException();
                }
            }

            if (!_context.Pets.Any(p => p.PetId == request.PetId))
            {
                throw new Exception("Invalid PetId provided.");
            }

            if (request.ServiceIds == null || !request.ServiceIds.Any())
            {
                throw new Exception("At least one ServiceId must be provided.");
            }

            foreach (var serviceId in request.ServiceIds)
            {
                var service = _context.Services.FirstOrDefault(s => s.ServiceId == serviceId);

                if (service == null)
                {
                    throw new Exception($"Invalid ServiceId provided: {serviceId}");
                }

                entity.AppointmentServices.Add(new Database.AppointmentService
                {
                    ServiceId = serviceId
                });
            }

            if (request.CreatedByAdmin == true)
            {
                entity.AppointmentStatusId = 2;
            }
            else if (request.AppointmentStatus.HasValue)
            {
                if (!_context.AppointmentStatuses.Any(s => s.AppointmentStatusId == request.AppointmentStatus.Value))
                {
                    throw new Exception("Invalid AppointmentStatusId provided.");
                }
                entity.AppointmentStatusId = request.AppointmentStatus.Value;
            }
            else
            {
                var defaultStatus = _context.AppointmentStatuses
                    .FirstOrDefault(s => s.AppointmentStatusId == 1);

                if (defaultStatus == null)
                {
                    throw new Exception("Default AppointmentStatus not found.");
                }

                entity.AppointmentStatusId = defaultStatus.AppointmentStatusId;
            }
        }

        public override Model.Appointment GetById(int id)
        {
            var entity = _context.Appointments
                .Include(a => a.Pet)
                    .ThenInclude(p => p.Owner)
                .Include(a => a.AppointmentStatus)
                .Include(a => a.AppointmentServices)
                    .ThenInclude(asv => asv.Service)
                .FirstOrDefault(a => a.AppointmentId == id);

            if (entity == null)
                return null!;

            return _mapper.Map<Model.Appointment>(entity);
        }

        public bool Approve(int id)
        {
            var appointment = _context.Appointments.Find(id);

            if (appointment == null)
                return false;

            if (!AppointmentStateMachine.CanTransition(appointment.AppointmentStatusId, (int)AppointmentStatusEnum.Approved))
                throw new InvalidOperationException("Status transition not allowed.");

            appointment.AppointmentStatusId = (int)AppointmentStatusEnum.Approved;

            _context.SaveChanges();

            return true;
        }

        public bool Reject(int id)
        {
            var appointment = _context.Appointments.Find(id);

            if (appointment == null)
                return false;

            if (!AppointmentStateMachine.CanTransition(appointment.AppointmentStatusId, (int)AppointmentStatusEnum.Rejected))
                throw new InvalidOperationException("Status transition not allowed.");

            appointment.AppointmentStatusId = (int)AppointmentStatusEnum.Rejected;

            _context.SaveChanges();

            return true;
        }

        public bool Complete(int id)
        {
            var appointment = _context.Appointments.Find(id);

            if (appointment == null)
                return false;

            if (!AppointmentStateMachine.CanTransition(appointment.AppointmentStatusId, (int)AppointmentStatusEnum.Completed))
                throw new InvalidOperationException("Cannot mark as completed from current status.");

            appointment.AppointmentStatusId = (int)AppointmentStatusEnum.Completed;
            _context.SaveChanges();

            return true;
        }

        public bool Cancel(int id)
        {
            var appointment = _context.Appointments.Find(id);

            if (appointment == null)
                return false;

            if (!AppointmentStateMachine.CanTransition(appointment.AppointmentStatusId, (int)AppointmentStatusEnum.Canceled))
                throw new InvalidOperationException("Cannot cancel from current status.");

            appointment.AppointmentStatusId = (int)AppointmentStatusEnum.Canceled;
            _context.SaveChanges();

            return true;
        }

        public override Model.Appointment Insert(AppointmentInsertRequest request)
        {
            var entity = base.Insert(request);

            var fullEntity = _context.Appointments
                .Include(a => a.Pet).ThenInclude(p => p.Owner)
                .Include(a => a.AppointmentStatus)
                .Include(a => a.AppointmentServices).ThenInclude(s => s.Service)
                .FirstOrDefault(a => a.AppointmentId == entity.AppointmentId);

            return _mapper.Map<Model.Appointment>(fullEntity);
        }

        public override Model.Appointment Update(int id, AppointmentUpdateRequest request)
        {
            var entity = base.Update(id, request);

            var fullEntity = _context.Appointments
                .Include(a => a.Pet).ThenInclude(p => p.Owner)
                .Include(a => a.AppointmentStatus)
                .Include(a => a.AppointmentServices).ThenInclude(s => s.Service)
                .FirstOrDefault(a => a.AppointmentId == entity.AppointmentId);

            return _mapper.Map<Model.Appointment>(fullEntity);
        }

        public void NotifyOwner(int appointmentId)
        {
            var appointment = _context.Appointments
                .Include(x => x.Pet).ThenInclude(p => p.Owner).Include(a => a.AppointmentServices).ThenInclude(asv => asv.Service)
                .FirstOrDefault(a => a.AppointmentId == appointmentId);

            if (appointment == null)
                return;

            var serviceNames = appointment.AppointmentServices
                       .Where(asv => asv.Service != null)
                       .Select(asv => asv.Service.Name)
                       .ToList();

            var servicesText = string.Join(", ", serviceNames);

            var message = new AppointmentNotificationMessage
            { 
                AppointmentId = appointment.AppointmentId,
                PetName = appointment.Pet.Name,
                OwnerEmail = appointment.Pet.Owner.Email,
                AppointmentDateTime = appointment.Date.Add(appointment.Time),
                Message = $"Reminder: Upcoming appointment for {appointment.Pet.Name} 's {servicesText} on {appointment.Date:dd.MM.yyyy} at {appointment.Time}"
            };

            _bus.PubSub.Publish(message);
        }

        private static DateTime RoundToMinute(DateTime dt)
        {
            return new DateTime(dt.Year, dt.Month, dt.Day, dt.Hour, dt.Minute, 0);
        }
    }
}

