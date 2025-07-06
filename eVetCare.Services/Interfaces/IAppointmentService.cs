using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
	public interface IAppointmentService : ICRUDService<Appointment, AppointmentSearchObject, AppointmentInsertRequest, AppointmentUpdateRequest>
    {
        bool Approve(int id);
        bool Reject(int id);
        bool Complete(int id);
        bool Cancel(int id);
        public void NotifyOwner(int appointmentId);
    }
}

