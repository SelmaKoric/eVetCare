using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace eVetCare.Services.Database
{
    public static class SeedData
    {
        public static void SeedDatabase(EVetCareContext context)
        {
            try
            {
                // Ensure database is created
                context.Database.EnsureCreated();

                // Seed data only if tables are empty
                if (!context.Genders.Any())
                {
                    SeedGenders(context);
                }

                if (!context.Species.Any())
                {
                    SeedSpecies(context);
                }

                if (!context.ServiceCategories.Any())
                {
                    SeedServiceCategories(context);
                }

                if (!context.Services.Any())
                {
                    SeedServices(context);
                }

                if (!context.AppointmentStatuses.Any())
                {
                    SeedAppointmentStatuses(context);
                }

                if (!context.Roles.Any())
                {
                    SeedRoles(context);
                }

                if (!context.Users.Any())
                {
                    SeedUsers(context);
                }

                if (!context.PaymentMethods.Any())
                {
                    SeedPaymentMethods(context);
                }

                context.SaveChanges();
            }
            catch (Exception ex)
            {
                // Log the exception for debugging
                Console.WriteLine($"Error seeding database: {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");
                throw;
            }
        }

        private static void SeedGenders(EVetCareContext context)
        {
            var genders = new List<Gender>
            {
                new Gender { Name = "Male" },
                new Gender { Name = "Female" }
            };

            context.Genders.AddRange(genders);
        }

        private static void SeedSpecies(EVetCareContext context)
        {
            var species = new List<Species>
            {
                new Species { Name = "Dog" },
                new Species { Name = "Cat" },
                new Species { Name = "Bird" },
                new Species { Name = "Rabbit" },
                new Species { Name = "Hamster" },
                new Species { Name = "Fish" },
                new Species { Name = "Horse" },
                new Species { Name = "Other" }
            };

            context.Species.AddRange(species);
        }

        private static void SeedServiceCategories(EVetCareContext context)
        {
            var categories = new List<ServiceCategory>
            {
                new ServiceCategory { Name = "General Checkup", IsActive = true },
                new ServiceCategory { Name = "Vaccination", IsActive = true },
                new ServiceCategory { Name = "Surgery", IsActive = true },
                new ServiceCategory { Name = "Dental Care", IsActive = true },
                new ServiceCategory { Name = "Laboratory", IsActive = true },
                new ServiceCategory { Name = "Emergency", IsActive = true },
                new ServiceCategory { Name = "Grooming", IsActive = true }
            };

            context.ServiceCategories.AddRange(categories);
        }

        private static void SeedServices(EVetCareContext context)
        {
            var generalCategory = context.ServiceCategories.FirstOrDefault(c => c.Name == "General Checkup");
            var vaccinationCategory = context.ServiceCategories.FirstOrDefault(c => c.Name == "Vaccination");
            var surgeryCategory = context.ServiceCategories.FirstOrDefault(c => c.Name == "Surgery");
            var dentalCategory = context.ServiceCategories.FirstOrDefault(c => c.Name == "Dental Care");
            var labCategory = context.ServiceCategories.FirstOrDefault(c => c.Name == "Laboratory");
            var emergencyCategory = context.ServiceCategories.FirstOrDefault(c => c.Name == "Emergency");
            var groomingCategory = context.ServiceCategories.FirstOrDefault(c => c.Name == "Grooming");

            var services = new List<Service>
            {
                // General Checkup Services
                new Service { Name = "Annual Health Check", Description = "Comprehensive annual health examination", Price = 75.00m, CategoryId = generalCategory?.CategoryId ?? 1, IsActive = true },
                new Service { Name = "Sick Pet Consultation", Description = "Consultation for sick pets", Price = 50.00m, CategoryId = generalCategory?.CategoryId ?? 1, IsActive = true },
                new Service { Name = "Weight Management", Description = "Weight management consultation", Price = 40.00m, CategoryId = generalCategory?.CategoryId ?? 1, IsActive = true },

                // Vaccination Services
                new Service { Name = "Rabies Vaccine", Description = "Rabies vaccination", Price = 25.00m, CategoryId = vaccinationCategory?.CategoryId ?? 2, IsActive = true },
                new Service { Name = "DHPP Vaccine (Dogs)", Description = "Core vaccine for dogs", Price = 30.00m, CategoryId = vaccinationCategory?.CategoryId ?? 2, IsActive = true },
                new Service { Name = "FVRCP Vaccine (Cats)", Description = "Core vaccine for cats", Price = 30.00m, CategoryId = vaccinationCategory?.CategoryId ?? 2, IsActive = true },

                // Surgery Services
                new Service { Name = "Spay/Neuter", Description = "Spaying or neutering procedure", Price = 200.00m, CategoryId = surgeryCategory?.CategoryId ?? 3, IsActive = true },
                new Service { Name = "Dental Surgery", Description = "Dental surgery procedures", Price = 300.00m, CategoryId = surgeryCategory?.CategoryId ?? 3, IsActive = true },
                new Service { Name = "Minor Surgery", Description = "Minor surgical procedures", Price = 150.00m, CategoryId = surgeryCategory?.CategoryId ?? 3, IsActive = true },

                // Dental Care Services
                new Service { Name = "Dental Cleaning", Description = "Professional dental cleaning", Price = 120.00m, CategoryId = dentalCategory?.CategoryId ?? 4, IsActive = true },
                new Service { Name = "Dental Examination", Description = "Dental health examination", Price = 45.00m, CategoryId = dentalCategory?.CategoryId ?? 4, IsActive = true },

                // Laboratory Services
                new Service { Name = "Blood Test", Description = "Complete blood count", Price = 60.00m, CategoryId = labCategory?.CategoryId ?? 5, IsActive = true },
                new Service { Name = "Urinalysis", Description = "Urine analysis", Price = 35.00m, CategoryId = labCategory?.CategoryId ?? 5, IsActive = true },
                new Service { Name = "Parasite Test", Description = "Fecal parasite examination", Price = 25.00m, CategoryId = labCategory?.CategoryId ?? 5, IsActive = true },

                // Emergency Services
                new Service { Name = "Emergency Consultation", Description = "Emergency medical consultation", Price = 100.00m, CategoryId = emergencyCategory?.CategoryId ?? 6, IsActive = true },
                new Service { Name = "Emergency Surgery", Description = "Emergency surgical procedures", Price = 500.00m, CategoryId = emergencyCategory?.CategoryId ?? 6, IsActive = true },

                // Grooming Services
                new Service { Name = "Basic Grooming", Description = "Basic grooming service", Price = 40.00m, CategoryId = groomingCategory?.CategoryId ?? 7, IsActive = true },
                new Service { Name = "Full Grooming", Description = "Complete grooming service", Price = 80.00m, CategoryId = groomingCategory?.CategoryId ?? 7, IsActive = true }
            };

            context.Services.AddRange(services);
        }

        private static void SeedAppointmentStatuses(EVetCareContext context)
        {
            var statuses = new List<AppointmentStatus>
            {
                new AppointmentStatus { Name = "Scheduled" },
                new AppointmentStatus { Name = "In Progress" },
                new AppointmentStatus { Name = "Completed" },
                new AppointmentStatus { Name = "Cancelled" },
                new AppointmentStatus { Name = "No Show" }
            };

            context.AppointmentStatuses.AddRange(statuses);
        }

        private static void SeedRoles(EVetCareContext context)
        {
            var roles = new List<Role>
            {
                new Role { RoleName = "Admin", IsActive = true },
                new Role { RoleName = "Veterinarian", IsActive = true },
                new Role { RoleName = "Receptionist", IsActive = true },
                new Role { RoleName = "Client", IsActive = true }
            };

            context.Roles.AddRange(roles);
        }

        private static void SeedUsers(EVetCareContext context)
        {
            var adminRole = context.Roles.FirstOrDefault(r => r.RoleName == "Admin");
            var clientRole = context.Roles.FirstOrDefault(r => r.RoleName == "Client");

            var users = new List<User>
            {
                new User 
                { 
                    FirstName = "Test", 
                    LastName = "User", 
                    Email = "string@example.com", 
                    Username = "string",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("string"), 
                    PhoneNumber = "123-456-7890",
                    IsActive = true,
                    IsAppUser = true
                }
            };

            context.Users.AddRange(users);
            context.SaveChanges(); // Save users first to get their IDs

            // Now create user-role relationships
            var testUser = context.Users.FirstOrDefault(u => u.Username == "string");

            var userRoles = new List<UserRole>();

            if (testUser != null && clientRole != null)
            {
                userRoles.Add(new UserRole
                {
                    UserId = testUser.UserId,
                    RoleId = clientRole.RoleId,
                    IsActive = true
                });
            }

            context.UserRoles.AddRange(userRoles);
        }

        private static void SeedPaymentMethods(EVetCareContext context)
        {
            var paymentMethods = new List<PaymentMethod>
            {
                new PaymentMethod { Name = "Credit Card", IsActive = true },
                new PaymentMethod { Name = "Debit Card", IsActive = true },
                new PaymentMethod { Name = "Cash", IsActive = true },
                new PaymentMethod { Name = "Insurance", IsActive = true }
            };

            context.PaymentMethods.AddRange(paymentMethods);
        }
    }
}
