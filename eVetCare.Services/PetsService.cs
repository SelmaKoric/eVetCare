using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services
{
    public class PetsService : BaseCRUDService<Pets, PetsSearchObject, Pet, PetsInsertRequest, PetsUpdateRequest>, IPetsService
    {
        public PetsService(EVetCareContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Pet> Filter(PetsSearchObject search, IQueryable<Pet> query)
        {
            var queryFilter = base.Filter(search, query);

            queryFilter = queryFilter
                .Include(p => p.Owner)
                .Include(p => p.Gender)
                .Include(p => p.Species);

            if (!string.IsNullOrWhiteSpace(search.NameOrOwnerName))
            {
                var searchText = search.NameOrOwnerName.Trim().ToLower();
                queryFilter = queryFilter.Where(x =>
                    x.Name.ToLower().Contains(searchText) ||
                    (x.Owner.FirstName + " " + x.Owner.LastName).ToLower().Contains(searchText));
            }

            if (search.OwnerId != null)
            {
                queryFilter = queryFilter.Where(x => x.OwnerId == search.OwnerId);
            }

            return queryFilter;
        }

        public override void BeforeInsert(PetsInsertRequest request, Pet entity)
        {
            if (request.OwnerId.HasValue)
            {
                var existingOwner = _context.Users.FirstOrDefault(u => u.UserId == request.OwnerId.Value);

                if (existingOwner == null)
                    throw new Exception("Selected owner does not exist.");

                entity.OwnerId = existingOwner.UserId;
            }
            else
            {
                var matchingOwner = _context.Users.FirstOrDefault(u =>
                    u.FirstName == request.OwnerFirstName &&
                    u.LastName == request.OwnerLastName);

                if (matchingOwner == null)
                {
                    var newOwner = new Database.User
                    {
                        FirstName = request.OwnerFirstName,
                        LastName = request.OwnerLastName,
                        Email = request.OwnerEmail,
                        PhoneNumber = request.OwnerPhoneNumber,
                        IsActive = true
                    };

                    _context.Users.Add(newOwner);
                    _context.SaveChanges();

                    entity.OwnerId = newOwner.UserId;
                }
                else
                {
                    entity.OwnerId = matchingOwner.UserId;
                }
            }

            if (request.GenderId.HasValue &&
                !_context.Genders.Any(g => g.GenderId == request.GenderId.Value))
            {
                throw new Exception("Invalid GenderId provided.");
            }

            entity.GenderId = request.GenderId;

            if (request.Photo != null)
            {
                var fileName = Guid.NewGuid() + Path.GetExtension(request.Photo.FileName);
                var folderPath = Path.Combine("wwwroot", "images", "pets");
                var filePath = Path.Combine(folderPath, fileName);

                Directory.CreateDirectory(folderPath);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    request.Photo.CopyTo(stream);
                }

                entity.PhotoUrl = "/images/pets/" + fileName;
            }
        }

        public override void BeforeUpdate(PetsUpdateRequest request, Pet entity)
        {

            if (request.Age.HasValue)
            {
                entity.Age = request.Age.Value;
            }
            if (request.Weight.HasValue)
            {
                entity.Weight = request.Weight.Value;
            }

            if (request.Photo != null)
            {
                var fileName = Guid.NewGuid() + Path.GetExtension(request.Photo.FileName);
                var filePath = Path.Combine("wwwroot", "images", "pets", fileName);

                Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    request.Photo.CopyTo(stream);
                }

                entity.PhotoUrl = "/images/pets/" + fileName;
            }
        }

        public override Model.Pets GetById(int id)
        {
            var entity = _context.Pets
                .Include(a => a.Owner)
                .Include(a => a.Gender)
                .Include(a => a.Species)
                .Include(a => a.Appointments)
                   .ThenInclude(a => a.AppointmentServices)
                   .ThenInclude(a => a.Service)
                .FirstOrDefault(a => a.PetId == id);

            if (entity == null)
                return null!;

            return _mapper.Map<Model.Pets>(entity);
        }
    }
}

