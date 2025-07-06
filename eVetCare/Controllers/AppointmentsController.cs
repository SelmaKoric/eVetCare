using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class AppointmentsController : BaseCRUDController<Model.Appointment, AppointmentSearchObject, AppointmentInsertRequest, AppointmentUpdateRequest>
    {
        public AppointmentsController(IAppointmentService service) : base(service)
        {
        }

        [HttpPut("{id}/approve")]
        [Authorize(Roles = "Admin")]
        public IActionResult Approve(int id)
        {
            var appointmentService = (IAppointmentService)_service;

            try
            {
                var success = appointmentService.Approve(id);
                if (!success)
                return NotFound();

                return Ok("Appointment approved.");
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}/reject")]
        [Authorize(Roles = "Admin")]
        public IActionResult Reject(int id)
        {
            var appointmentService = (IAppointmentService)_service;

            try
            {
                var success = appointmentService.Reject(id);
                if (!success)
                return NotFound();

                return Ok("Appointment rejected.");
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}/complete")]
        [Authorize(Roles = "Admin")]
        public IActionResult Complete(int id)
        {
            var appointmentService = (IAppointmentService)_service;

            try
            {
                var success = appointmentService.Complete(id);
                if (!success) return NotFound();
                return Ok("Appointment marked as completed.");
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}/cancel")]
        [Authorize(Roles = "Admin")]
        public IActionResult Cancel(int id)
        {
            var appointmentService = (IAppointmentService)_service;

            try
            {
                var success = appointmentService.Cancel(id);
                if (!success) return NotFound();
                return Ok("Appointment canceled.");
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}

