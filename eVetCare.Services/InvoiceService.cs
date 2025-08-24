using System;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
	public class InvoiceService : BaseCRUDService<Model.Invoice, InvoiceSearchObject, Database.Invoice, InvoiceInsertRequest, object>, IInvoiceService
    {
        public InvoiceService(EVetCareContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Invoice> Filter(InvoiceSearchObject search, IQueryable<Invoice> query)
        {
            var queryFilter = base.Filter(search, query);

            queryFilter = query.Include(x=>x.InvoiceItems);

            if (search.IssueDate != null)
            {
                queryFilter = queryFilter.Where(x => x.IssueDate.Date.Equals(search.IssueDate));
            }

            return queryFilter;
        }

        protected override void BeforeInsert(InvoiceInsertRequest request, Database.Invoice entity)
        {
            var appointment = _context.Appointments
                .Include(a => a.AppointmentServices)
                .ThenInclude(x => x.Service)
                .FirstOrDefault(a => a.AppointmentId == request.AppointmentId);

            if (appointment == null)
                throw new Exception("Appointment not found.");

            entity.AppointmentId = request.AppointmentId;
            entity.IssueDate = request.IssueDate;

            entity.InvoiceItems ??= new List<Database.InvoiceItem>();

            if (request.ServiceIds == null || request.ServiceIds.Count == 0)
                throw new Exception("At least one ServiceId is required.");

            decimal totalAmount = 0m;

            foreach (var serviceId in request.ServiceIds)
            {
                var service = _context.Services.FirstOrDefault(s => s.ServiceId == serviceId)
                              ?? throw new Exception($"Service with ID {serviceId} not found.");

                entity.InvoiceItems.Add(new Database.InvoiceItem { ServiceId = serviceId });
                totalAmount += service.Price ?? 0m;
            }

            entity.TotalAmount = totalAmount;
        }

        public override Model.Invoice GetById(int id)
        {
            var entity = _context.Invoices
                .Include(x => x.InvoiceItems)
                .ThenInclude(ii => ii.Service)
                .FirstOrDefault(x => x.InvoiceId == id);

            if (entity == null)
                return null;

            return _mapper.Map<Model.Invoice>(entity);
        }
    }
}

