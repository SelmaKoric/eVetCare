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

                // Save changes after seeding basic data
                context.SaveChanges();

                // Seed dependent data
                if (!context.Pets.Any())
                {
                    SeedPets(context);
                }

                if (!context.Appointments.Any())
                {
                    SeedAppointments(context);
                }

                if (!context.MedicalRecords.Any())
                {
                    SeedMedicalRecords(context);
                }

                if (!context.Invoices.Any())
                {
                    SeedInvoices(context);
                }

                if (!context.Payments.Any())
                {
                    SeedPayments(context);
                }

                if (!context.Vaccinations.Any())
                {
                    SeedVaccinations(context);
                }

                if (!context.LabTests.Any())
                {
                    SeedLabTests(context);
                }

                // LabResults are seeded within SeedLabTests method

                if (!context.Treatments.Any())
                {
                    SeedTreatments(context);
                }

                if (!context.Diagnoses.Any())
                {
                    SeedDiagnoses(context);
                }

                if (!context.Recommendations.Any())
                {
                    SeedRecommendations(context);
                }

                if (!context.Reminders.Any())
                {
                    SeedReminders(context);
                }

                if (!context.Notifications.Any())
                {
                    SeedNotifications(context);
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
                new Gender { Name = "Male", IsActive = true },
                new Gender { Name = "Female", IsActive = true }
            };

            context.Genders.AddRange(genders);
        }

        private static void SeedSpecies(EVetCareContext context)
        {
            var species = new List<Species>
            {
                new Species { Name = "Dog", IsActive = true },
                new Species { Name = "Cat", IsActive = true },
                new Species { Name = "Bird", IsActive = true },
                new Species { Name = "Rabbit", IsActive = true },
                new Species { Name = "Hamster", IsActive = true },
                new Species { Name = "Fish", IsActive = true },
                new Species { Name = "Horse", IsActive = true },
                new Species { Name = "Other", IsActive = true }
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
                new Service { Name = "Annual Health Check", Description = "Comprehensive annual health examination", Price = 75.00m, DurationMinutes = 30, CategoryId = generalCategory?.CategoryId ?? 1, IsActive = true },
                new Service { Name = "Sick Pet Consultation", Description = "Consultation for sick pets", Price = 50.00m, DurationMinutes = 20, CategoryId = generalCategory?.CategoryId ?? 1, IsActive = true },
                new Service { Name = "Weight Management", Description = "Weight management consultation", Price = 40.00m, DurationMinutes = 15, CategoryId = generalCategory?.CategoryId ?? 1, IsActive = true },

                // Vaccination Services
                new Service { Name = "Rabies Vaccine", Description = "Rabies vaccination", Price = 25.00m, DurationMinutes = 10, CategoryId = vaccinationCategory?.CategoryId ?? 2, IsActive = true },
                new Service { Name = "DHPP Vaccine (Dogs)", Description = "Core vaccine for dogs", Price = 30.00m, DurationMinutes = 10, CategoryId = vaccinationCategory?.CategoryId ?? 2, IsActive = true },
                new Service { Name = "FVRCP Vaccine (Cats)", Description = "Core vaccine for cats", Price = 30.00m, DurationMinutes = 10, CategoryId = vaccinationCategory?.CategoryId ?? 2, IsActive = true },

                // Surgery Services
                new Service { Name = "Spay/Neuter", Description = "Spaying or neutering procedure", Price = 200.00m, DurationMinutes = 120, CategoryId = surgeryCategory?.CategoryId ?? 3, IsActive = true },
                new Service { Name = "Dental Surgery", Description = "Dental surgery procedures", Price = 300.00m, DurationMinutes = 90, CategoryId = surgeryCategory?.CategoryId ?? 3, IsActive = true },
                new Service { Name = "Minor Surgery", Description = "Minor surgical procedures", Price = 150.00m, DurationMinutes = 60, CategoryId = surgeryCategory?.CategoryId ?? 3, IsActive = true },

                // Dental Care Services
                new Service { Name = "Dental Cleaning", Description = "Professional dental cleaning", Price = 120.00m, DurationMinutes = 45, CategoryId = dentalCategory?.CategoryId ?? 4, IsActive = true },
                new Service { Name = "Dental Examination", Description = "Dental health examination", Price = 45.00m, DurationMinutes = 15, CategoryId = dentalCategory?.CategoryId ?? 4, IsActive = true },

                // Laboratory Services
                new Service { Name = "Blood Test", Description = "Complete blood count", Price = 60.00m, DurationMinutes = 20, CategoryId = labCategory?.CategoryId ?? 5, IsActive = true },
                new Service { Name = "Urinalysis", Description = "Urine analysis", Price = 35.00m, DurationMinutes = 15, CategoryId = labCategory?.CategoryId ?? 5, IsActive = true },
                new Service { Name = "Parasite Test", Description = "Fecal parasite examination", Price = 25.00m, DurationMinutes = 10, CategoryId = labCategory?.CategoryId ?? 5, IsActive = true },

                // Emergency Services
                new Service { Name = "Emergency Consultation", Description = "Emergency medical consultation", Price = 100.00m, DurationMinutes = 30, CategoryId = emergencyCategory?.CategoryId ?? 6, IsActive = true },
                new Service { Name = "Emergency Surgery", Description = "Emergency surgical procedures", Price = 500.00m, DurationMinutes = 180, CategoryId = emergencyCategory?.CategoryId ?? 6, IsActive = true },

                // Grooming Services
                new Service { Name = "Basic Grooming", Description = "Basic grooming service", Price = 40.00m, DurationMinutes = 60, CategoryId = groomingCategory?.CategoryId ?? 7, IsActive = true },
                new Service { Name = "Full Grooming", Description = "Complete grooming service", Price = 80.00m, DurationMinutes = 120, CategoryId = groomingCategory?.CategoryId ?? 7, IsActive = true }
            };

            context.Services.AddRange(services);
        }

        private static void SeedAppointmentStatuses(EVetCareContext context)
        {
            var statuses = new List<AppointmentStatus>
            {
                new AppointmentStatus { Name = "Scheduled", IsActive = true },
                new AppointmentStatus { Name = "In Progress", IsActive = true },
                new AppointmentStatus { Name = "Completed", IsActive = true },
                new AppointmentStatus { Name = "Cancelled", IsActive = true },
                new AppointmentStatus { Name = "No Show", IsActive = true }
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
            var vetRole = context.Roles.FirstOrDefault(r => r.RoleName == "Veterinarian");
            var receptionistRole = context.Roles.FirstOrDefault(r => r.RoleName == "Receptionist");

            var users = new List<User>
            {
                // Test client user
                new User 
                { 
                    FirstName = "John", 
                    LastName = "Doe", 
                    Email = "john.doe@example.com", 
                    Username = "johndoe",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("password123"), 
                    PhoneNumber = "123-456-7890",
                    IsActive = true,
                    IsAppUser = true
                },
                // Admin user
                new User 
                { 
                    FirstName = "Admin", 
                    LastName = "User", 
                    Email = "admin@evetcare.com", 
                    Username = "admin",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"), 
                    PhoneNumber = "555-000-0001",
                    IsActive = true,
                    IsAppUser = false
                },
                // Veterinarian
                new User 
                { 
                    FirstName = "Dr. Sarah", 
                    LastName = "Johnson", 
                    Email = "sarah.johnson@evetcare.com", 
                    Username = "dr.sarah",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("vet123"), 
                    PhoneNumber = "555-000-0002",
                    IsActive = true,
                    IsAppUser = false
                },
                // Receptionist
                new User 
                { 
                    FirstName = "Mary", 
                    LastName = "Smith", 
                    Email = "mary.smith@evetcare.com", 
                    Username = "mary.smith",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("reception123"), 
                    PhoneNumber = "555-000-0003",
                    IsActive = true,
                    IsAppUser = false
                },
                // Additional client
                new User 
                { 
                    FirstName = "Jane", 
                    LastName = "Wilson", 
                    Email = "jane.wilson@example.com", 
                    Username = "janewilson",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("password123"), 
                    PhoneNumber = "123-456-7891",
                    IsActive = true,
                    IsAppUser = true
                }
            };

            context.Users.AddRange(users);
            context.SaveChanges(); // Save users first to get their IDs

            // Create user-role relationships
            var userRoles = new List<UserRole>();

            // Assign roles to users
            var johnDoe = context.Users.FirstOrDefault(u => u.Username == "johndoe");
            var adminUser = context.Users.FirstOrDefault(u => u.Username == "admin");
            var drSarah = context.Users.FirstOrDefault(u => u.Username == "dr.sarah");
            var marySmith = context.Users.FirstOrDefault(u => u.Username == "mary.smith");
            var janeWilson = context.Users.FirstOrDefault(u => u.Username == "janewilson");

            if (johnDoe != null && clientRole != null)
            {
                userRoles.Add(new UserRole { UserId = johnDoe.UserId, RoleId = clientRole.RoleId, IsActive = true });
            }

            if (adminUser != null && adminRole != null)
            {
                userRoles.Add(new UserRole { UserId = adminUser.UserId, RoleId = adminRole.RoleId, IsActive = true });
            }

            if (drSarah != null && vetRole != null)
            {
                userRoles.Add(new UserRole { UserId = drSarah.UserId, RoleId = vetRole.RoleId, IsActive = true });
            }

            if (marySmith != null && receptionistRole != null)
            {
                userRoles.Add(new UserRole { UserId = marySmith.UserId, RoleId = receptionistRole.RoleId, IsActive = true });
            }

            if (janeWilson != null && clientRole != null)
            {
                userRoles.Add(new UserRole { UserId = janeWilson.UserId, RoleId = clientRole.RoleId, IsActive = true });
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

        private static void SeedPets(EVetCareContext context)
        {
            var dogSpecies = context.Species.FirstOrDefault(s => s.Name == "Dog");
            var catSpecies = context.Species.FirstOrDefault(s => s.Name == "Cat");
            var maleGender = context.Genders.FirstOrDefault(g => g.Name == "Male");
            var femaleGender = context.Genders.FirstOrDefault(g => g.Name == "Female");
            var johnDoe = context.Users.FirstOrDefault(u => u.Username == "johndoe");
            var janeWilson = context.Users.FirstOrDefault(u => u.Username == "janewilson");

            var pets = new List<Pet>
            {
                new Pet
                {
                    OwnerId = johnDoe?.UserId ?? 1,
                    Name = "Buddy",
                    SpeciesId = dogSpecies?.SpeciesId ?? 1,
                    Breed = "Golden Retriever",
                    Age = 3,
                    Weight = 65.5,
                    GenderId = maleGender?.GenderId ?? 1,
                    IsActive = true
                },
                new Pet
                {
                    OwnerId = johnDoe?.UserId ?? 1,
                    Name = "Whiskers",
                    SpeciesId = catSpecies?.SpeciesId ?? 2,
                    Breed = "Persian",
                    Age = 2,
                    Weight = 8.2,
                    GenderId = femaleGender?.GenderId ?? 2,
                    IsActive = true
                },
                new Pet
                {
                    OwnerId = janeWilson?.UserId ?? 5,
                    Name = "Max",
                    SpeciesId = dogSpecies?.SpeciesId ?? 1,
                    Breed = "German Shepherd",
                    Age = 4,
                    Weight = 75.0,
                    GenderId = maleGender?.GenderId ?? 1,
                    IsActive = true
                }
            };

            context.Pets.AddRange(pets);
        }

        private static void SeedAppointments(EVetCareContext context)
        {
            var scheduledStatus = context.AppointmentStatuses.FirstOrDefault(s => s.Name == "Scheduled");
            var completedStatus = context.AppointmentStatuses.FirstOrDefault(s => s.Name == "Completed");
            var inProgressStatus = context.AppointmentStatuses.FirstOrDefault(s => s.Name == "In Progress");
            
            var pets = context.Pets.ToList();
            var services = context.Services.ToList();

            if (!pets.Any() || !services.Any()) return;

            var appointments = new List<Appointment>
            {
                new Appointment
                {
                    PetId = pets[0].PetId, // Buddy
                    Date = DateTime.Today.AddDays(7),
                    Time = new TimeSpan(10, 0, 0),
                    AppointmentStatusId = scheduledStatus?.AppointmentStatusId ?? 1,
                    Duration = new TimeSpan(0, 30, 0),
                    IsActive = true,
                    CreatedByAdmin = false
                },
                new Appointment
                {
                    PetId = pets[1].PetId, // Whiskers
                    Date = DateTime.Today.AddDays(-3),
                    Time = new TimeSpan(14, 30, 0),
                    AppointmentStatusId = completedStatus?.AppointmentStatusId ?? 3,
                    Duration = new TimeSpan(0, 20, 0),
                    IsActive = true,
                    CreatedByAdmin = false
                },
                new Appointment
                {
                    PetId = pets[2].PetId, // Max
                    Date = DateTime.Today.AddDays(1),
                    Time = new TimeSpan(9, 0, 0),
                    AppointmentStatusId = scheduledStatus?.AppointmentStatusId ?? 1,
                    Duration = new TimeSpan(0, 45, 0),
                    IsActive = true,
                    CreatedByAdmin = true
                }
            };

            context.Appointments.AddRange(appointments);
            context.SaveChanges();

            // Add appointment services
            var appointmentServices = new List<AppointmentService>();
            var annualCheckup = services.FirstOrDefault(s => s.Name == "Annual Health Check");
            var sickConsultation = services.FirstOrDefault(s => s.Name == "Sick Pet Consultation");
            var dentalCleaning = services.FirstOrDefault(s => s.Name == "Dental Cleaning");

            if (annualCheckup != null && appointments.Count > 0)
            {
                appointmentServices.Add(new AppointmentService
                {
                    AppointmentId = appointments[0].AppointmentId,
                    ServiceId = annualCheckup.ServiceId,
                    IsActive = true
                });
            }

            if (sickConsultation != null && appointments.Count > 1)
            {
                appointmentServices.Add(new AppointmentService
                {
                    AppointmentId = appointments[1].AppointmentId,
                    ServiceId = sickConsultation.ServiceId,
                    IsActive = true
                });
            }

            if (dentalCleaning != null && appointments.Count > 2)
            {
                appointmentServices.Add(new AppointmentService
                {
                    AppointmentId = appointments[2].AppointmentId,
                    ServiceId = dentalCleaning.ServiceId,
                    IsActive = true
                });
            }

            context.AppointmentServices.AddRange(appointmentServices);
        }

        private static void SeedMedicalRecords(EVetCareContext context)
        {
            var appointments = context.Appointments.ToList();
            if (!appointments.Any()) return;

            var medicalRecords = new List<MedicalRecord>
            {
                new MedicalRecord
                {
                    PetId = appointments[1].PetId, // Whiskers
                    AppointmentId = appointments[1].AppointmentId, // Whiskers' completed appointment
                    Date = DateTime.Today.AddDays(-3),
                    Notes = "Patient presented with mild lethargy and decreased appetite. Temperature normal. Recommended rest and monitoring.",
                    AnalysisProvided = "Physical examination completed. No abnormalities detected.",
                    IsActive = true
                }
            };

            context.MedicalRecords.AddRange(medicalRecords);
        }

        private static void SeedInvoices(EVetCareContext context)
        {
            var appointments = context.Appointments.ToList();
            var paymentMethods = context.PaymentMethods.ToList();
            
            if (!appointments.Any() || !paymentMethods.Any()) return;

            var invoices = new List<Invoice>
            {
                new Invoice
                {
                    AppointmentId = appointments[1].AppointmentId, // Whiskers' appointment
                    TotalAmount = 55.00m,
                    IssueDate = DateTime.Today.AddDays(-3),
                    IsActive = true
                }
            };

            context.Invoices.AddRange(invoices);
            context.SaveChanges();

            // Add invoice items
            var services = context.Services.ToList();
            var sickConsultation = services.FirstOrDefault(s => s.Name == "Sick Pet Consultation");
            
            if (sickConsultation != null && invoices.Any())
            {
                var invoiceItems = new List<InvoiceItem>
                {
                    new InvoiceItem
                    {
                        InvoiceId = invoices[0].InvoiceId,
                        ServiceId = sickConsultation.ServiceId,
                        IsActive = true
                    }
                };

                context.InvoiceItems.AddRange(invoiceItems);
            }
        }

        private static void SeedPayments(EVetCareContext context)
        {
            var invoices = context.Invoices.ToList();
            var paymentMethods = context.PaymentMethods.ToList();
            
            if (!invoices.Any() || !paymentMethods.Any()) return;

            var creditCard = paymentMethods.FirstOrDefault(pm => pm.Name == "Credit Card");
            
            var payments = new List<Payment>
            {
                new Payment
                {
                    InvoiceId = invoices[0].InvoiceId,
                    MethodId = creditCard?.MethodId ?? 1,
                    Amount = invoices[0].TotalAmount,
                    PaymentDate = DateTime.Today.AddDays(-2),
                    PaymentIntentId = "TXN" + DateTime.Now.Ticks.ToString().Substring(0, 8),
                    IsActive = true
                }
            };

            context.Payments.AddRange(payments);
        }

        private static void SeedVaccinations(EVetCareContext context)
        {
            var pets = context.Pets.ToList();
            if (!pets.Any()) return;

            var medicalRecords = context.MedicalRecords.ToList();
            if (medicalRecords.Any())
            {
                var vaccinations = new List<Vaccination>
                {
                    new Vaccination
                    {
                        Name = "Rabies",
                        DateGiven = DateTime.Today.AddDays(-30),
                        NextDue = DateTime.Today.AddDays(335),
                        MedicalRecordId = medicalRecords[0].MedicalRecordId,
                        IsActive = true
                    }
                };

                context.Vaccinations.AddRange(vaccinations);
            }
        }

        private static void SeedLabTests(EVetCareContext context)
        {
            var appointments = context.Appointments.ToList();
            if (!appointments.Any()) return;

            var labTests = new List<LabTest>
            {
                new LabTest
                {
                    Name = "Complete Blood Count",
                    Unit = "cells/μL",
                    ReferenceRange = "4.5-11.0 x 10^3",
                    IsActive = true
                }
            };

            context.LabTests.AddRange(labTests);
            context.SaveChanges();

            // Add lab results
            var medicalRecords = context.MedicalRecords.ToList();
            if (medicalRecords.Any() && labTests.Any())
            {
                var labResults = new List<LabResult>
                {
                    new LabResult
                    {
                        LabTestId = labTests[0].LabTestId,
                        MedicalRecordId = medicalRecords[0].MedicalRecordId,
                        ResultValue = "Normal",
                        IsActive = true
                    }
                };

                context.LabResults.AddRange(labResults);
            }
        }

        private static void SeedTreatments(EVetCareContext context)
        {
            var appointments = context.Appointments.ToList();
            if (!appointments.Any()) return;

            var medicalRecords = context.MedicalRecords.ToList();
            if (medicalRecords.Any())
            {
                var treatments = new List<Treatment>
                {
                    new Treatment
                    {
                        MedicalRecordId = medicalRecords[0].MedicalRecordId, // Whiskers' medical record
                        TreatmentDescription = "Supportive care, rest, and monitoring for 7 days",
                        IsActive = true
                    }
                };

                context.Treatments.AddRange(treatments);
            }
        }

        private static void SeedDiagnoses(EVetCareContext context)
        {
            var appointments = context.Appointments.ToList();
            if (!appointments.Any()) return;

            var medicalRecords = context.MedicalRecords.ToList();
            if (medicalRecords.Any())
            {
                var diagnoses = new List<Diagnosis>
                {
                    new Diagnosis
                    {
                        MedicalRecordId = medicalRecords[0].MedicalRecordId, // Whiskers' medical record
                        Description = "Mild upper respiratory infection",
                        IsActive = true
                    }
                };

                context.Diagnoses.AddRange(diagnoses);
            }
        }

        private static void SeedRecommendations(EVetCareContext context)
        {
            var pets = context.Pets.ToList();
            if (!pets.Any()) return;

            var recommendations = new List<Recommendation>
            {
                new Recommendation
                {
                    PetId = pets[0].PetId, // Buddy
                    Content = "Schedule annual vaccination booster in 3 months",
                    CreatedAt = DateTime.Now,
                    IsActive = true
                },
                new Recommendation
                {
                    PetId = pets[1].PetId, // Whiskers
                    Content = "Monitor appetite and energy levels. Return if symptoms worsen.",
                    CreatedAt = DateTime.Now,
                    IsActive = true
                }
            };

            context.Recommendations.AddRange(recommendations);
        }

        private static void SeedReminders(EVetCareContext context)
        {
            var users = context.Users.ToList();
            if (!users.Any()) return;

            var reminders = new List<Reminder>
            {
                new Reminder
                {
                    UserId = users[0].UserId, // John Doe
                    Type = "Vaccination",
                    TargetDate = DateTime.Today.AddDays(14),
                    IsActive = true
                },
                new Reminder
                {
                    UserId = users[4].UserId, // Jane Wilson
                    Type = "Appointment",
                    TargetDate = DateTime.Today.AddDays(1),
                    IsActive = true
                }
            };

            context.Reminders.AddRange(reminders);
        }

        private static void SeedNotifications(EVetCareContext context)
        {
            var users = context.Users.ToList();
            if (!users.Any()) return;

            var notifications = new List<Notification>
            {
                new Notification
                {
                    UserId = users[0].UserId, // John Doe
                    Message = "Your appointment with Buddy has been confirmed for next week.",
                    DateTimeSent = DateTime.Now,
                    IsRead = false,
                    IsActive = true
                },
                new Notification
                {
                    UserId = users[4].UserId, // Jane Wilson
                    Message = "Payment for Max's dental cleaning has been processed successfully.",
                    DateTimeSent = DateTime.Now.AddDays(-1),
                    IsRead = true,
                    IsActive = true
                }
            };

            context.Notifications.AddRange(notifications);
        }
    }
}
