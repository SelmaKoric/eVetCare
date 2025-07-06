using System;
using eVetCare.Model.Requests;
using eVetCare.Services.Database;
using Mapster;

namespace eVetCare.Services.Mapping
{
    public static class MapsterConfig
    {
        public static void RegisterMappings()
        {
            TypeAdapterConfig<Appointment, Model.Appointment>
                .NewConfig()
                .Map(dest => dest.Date, src => src.Date.ToString("yyyy-MM-dd"))
               .Map(dest => dest.Time, src => src.Time.ToString(@"hh\:mm"))
                .Map(dest => dest.PetName, src => src.Pet != null ? src.Pet.Name : "")
                .Map(dest => dest.OwnerName, src => src.Pet != null && src.Pet.Owner != null ? src.Pet.Owner.FirstName + " " + src.Pet.Owner.LastName : "")
                .Map(dest => dest.Status, src => src.AppointmentStatus != null ? src.AppointmentStatus.Name : "")
                .Map(dest => dest.ServiceNames, src =>
                    src.AppointmentServices != null
                        ? src.AppointmentServices
                            .Where(s => s.Service != null)
                            .Select(s => new Model.AppointmentService
                            {
                                Name = s.Service.Name,
                                Description = s.Service.Description
                            }).ToList()
                        : new List<Model.AppointmentService>());


            TypeAdapterConfig.GlobalSettings.Default.IgnoreNullValues(true);
            TypeAdapterConfig<AppointmentInsertRequest, Appointment>
                .NewConfig()
                .Ignore(dest => dest.AppointmentStatus);

            TypeAdapterConfig<Pet, eVetCare.Model.Pets>
                .NewConfig()
                .Map(dest => dest.PhotoUrl, src => src.PhotoUrl)
                .Map(dest => dest.OwnerName, src => src.Owner != null ? src.Owner.FirstName + " " + src.Owner.LastName : "")
                .Map(dest => dest.OwnerPhoneNumber, src => src.Owner.PhoneNumber)
                .Map(dest => dest.OwnerEmail, src => src.Owner.Email)
                .Map(dest => dest.Species, src => src.Species != null ? src.Species.Name : "")
                .Map(dest => dest.GenderName, src => src.Gender != null ? src.Gender.Name : "");

        }
    }
}

