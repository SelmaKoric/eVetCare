using System;
using System.Linq;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
	public class MedicalRecordService : BaseService<Model.MedicalRecord, MedicalRecordSearchObject, Database.MedicalRecord>, IMedicalRecordService
	{
        public MedicalRecordService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.MedicalRecord> Filter(MedicalRecordSearchObject search, IQueryable<Database.MedicalRecord> query)
        {
            var queryFilter = base.Filter(search, query);

            queryFilter = query.Include(p => p.Pet).AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.PetName))
            {
                queryFilter = queryFilter.Where(x => x.Pet.Name.Contains(search.PetName));
            }

            if (search.AppointmentId != null)
            {
                queryFilter = queryFilter.Where(x => x.Appointment.AppointmentId.Equals(search.AppointmentId));
            }

            if (search.Date != null)
            {
                queryFilter = queryFilter.Where(x => x.Date.Equals(search.Date));
            }

            //if (!string.IsNullOrWhiteSpace(search.DiagnosisKeyword))
            //{
            //    queryFilter = queryFilter.Where(x => x.Diagnoses.Any(d => d.Description.Contains(search.DiagnosisKeyword)));
            //}

            //if (!string.IsNullOrWhiteSpace(search.TreatmentKeyword))
            //{
            //    queryFilter = queryFilter.Where(x => x.Treatments.Any(d => d.TreatmentDescription.Contains(search.DiagnosisKeyword)));
            //}

            if (search.IncludeDiagnoses == true)
            {
                queryFilter = queryFilter.Include(x => x.Diagnoses);
            }

            if (search.IncludeTreatments == true)
            {
                queryFilter = queryFilter.Include(x => x.Treatments);
            }

            if (search.IncludeLabResults == true)
            {
                queryFilter = queryFilter.Include(x => x.LabResults);
            }

            if (search.IncludeVaccinations == true)
            {
                queryFilter = queryFilter.Include(x => x.Vaccinations);
            }

            return queryFilter;
        }

        public override Model.MedicalRecord GetById(int id)
        {
            var entity = _context.MedicalRecords
                .Include(m => m.Pet)
                .Include(m => m.Diagnoses)
                .Include(m => m.Treatments)
                .Include(m => m.LabResults)
                .FirstOrDefault(m => m.MedicalRecordId == id);

            if (entity == null)
                return null!;

            return _mapper.Map<Model.MedicalRecord>(entity);
        }
    }
}

