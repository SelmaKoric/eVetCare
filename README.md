# eVetCare - Veterinary Clinic Management System

A comprehensive veterinary clinic management system built with .NET Core and Flutter.

## Features

- **Appointment Management**: Schedule and manage veterinary appointments
- **Pet Management**: Complete pet profiles and medical history
- **Medical Records**: Track diagnoses, treatments, and lab results
- **Billing & Payments**: Invoice generation and payment processing
- **User Management**: Multi-role system (Admin, Veterinarian, Receptionist, Client)
- **Notifications**: Real-time notifications and reminders
- **Analytics**: Clinic performance and patient analytics

## Technology Stack

### Backend
- **.NET 9.0** - Core framework
- **Entity Framework Core** - ORM and database management
- **SQL Server** - Database
- **RabbitMQ** - Message queuing
- **JWT** - Authentication
- **Stripe** - Payment processing

### Frontend
- **Flutter** - Cross-platform mobile and web applications
- **Dart** - Programming language

## Database Seeding

The application includes comprehensive seed data that creates a realistic veterinary clinic environment with:

### Users & Roles
- **Admin User**: `admin` / `admin123`
- **Veterinarian**: `dr.sarah` / `vet123`
- **Receptionist**: `mary.smith` / `reception123`
- **Client Users**: 
  - `johndoe` / `password123`
  - `janewilson` / `password123`

### Sample Data
- **Pets**: 3 pets (Buddy - Golden Retriever, Whiskers - Persian Cat, Max - German Shepherd)
- **Appointments**: Past and future appointments with different statuses
- **Services**: 17 veterinary services across 7 categories
- **Medical Records**: Complete medical history with diagnoses and treatments
- **Invoices & Payments**: Sample billing data
- **Vaccinations**: Vaccination records with due dates
- **Lab Tests**: Laboratory test results
- **Notifications & Reminders**: System notifications and appointment reminders

### Automatic Seeding
The database is automatically seeded when the application starts. The seeding process:
1. Creates basic lookup data (genders, species, service categories, etc.)
2. Creates users and assigns roles
3. Creates sample pets and appointments
4. Generates medical records, invoices, and other related data
5. Only seeds data if tables are empty (safe to run multiple times)

## Getting Started

### Option 1: Docker (Recommended)

The easiest way to run eVetCare is using Docker. This will set up all required services automatically.

#### Prerequisites
- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose

#### Quick Start with Docker
1. Clone the repository
2. Copy the environment template:
   ```bash
   cp env.example .env
   ```
3. Edit `.env` file with your configuration
4. Run the application:
   ```bash
   docker-compose up --build
   ```
5. Access the application:
   - API: http://localhost:8080
   - Swagger: http://localhost:8080/swagger
   - RabbitMQ: http://localhost:15672 (guest/guest)

For detailed Docker instructions, see [DOCKER_README.md](DOCKER_README.md).

### Option 2: Manual Setup

#### Prerequisites
- .NET 9.0 SDK
- SQL Server (or SQL Server Express)
- Flutter SDK (for mobile/web apps)
- RabbitMQ (for notifications)

#### Backend Setup
1. Clone the repository
2. Update connection strings in `appsettings.json`
3. Run the application:
   ```bash
   cd eVetCare
   dotnet run
   ```
4. The database will be automatically created and seeded

### Frontend Setup
1. Navigate to the UI directory:
   ```bash
   cd UI/evetcare_mobile
   flutter pub get
   flutter run
   ```

## API Documentation
Once the backend is running, you can access the Swagger documentation at:
`http://localhost:8080/swagger`

## Default Login Credentials

### Admin Access
- Username: `admin`
- Password: `admin123`

### Client Access
- Username: `johndoe`
- Password: `password123`

## Database Schema

The system includes the following main entities:
- **Users & Roles**: Multi-role user management
- **Pets**: Pet profiles with species, breed, and owner information
- **Appointments**: Scheduling with status tracking
- **Services**: Veterinary services with pricing
- **Medical Records**: Complete medical history
- **Invoices & Payments**: Billing and payment processing
- **Lab Tests & Results**: Laboratory testing
- **Vaccinations**: Vaccination tracking
- **Notifications & Reminders**: Communication system

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.