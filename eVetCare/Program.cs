using EasyNetQ;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using System.Text;
using eVetCare.Model.Requests;
using eVetCare.Notifications;
using eVetCare.Services;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using Mapster;
using MapsterMapper;

using Microsoft.EntityFrameworkCore;
using Stripe;
using AppointmentService = eVetCare.Services.AppointmentService;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;
using eVetCare.Services.Mapping;
using eVetCare.API.Filters;

var builder = WebApplication.CreateBuilder(args);

MapsterConfig.RegisterMappings();


TypeAdapterConfig<eVetCare.Services.Database.Payment, eVetCare.Model.Payment>
    .NewConfig()
    .Map(dest => dest.MethodName, src => src.Method.Name);


// Add services to the container.

builder.Services.AddDbContext<EVetCareContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions => sqlOptions.EnableRetryOnFailure(
            maxRetryCount: 5,
            maxRetryDelay: TimeSpan.FromSeconds(10),
            errorNumbersToAdd: null)
    ));


builder.Services.AddSingleton(RabbitHutch.CreateBus("host=localhost;username=guest;password=guest"));
builder.Services.AddMapster();

builder.Services.AddControllers();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "eVetCare API", Version = "v1" });
    c.SchemaFilter<TimeSpanSchemaFilter>();

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});


builder.Services.AddTransient<IPetsService, PetsService>();
builder.Services.AddTransient<IMedicalRecordService, MedicalRecordService>();
builder.Services.AddTransient<ILabResultService, LabResultService>();
builder.Services.AddTransient<ITreatmentService, TreatmentService>();
builder.Services.AddTransient<IDiagnosesService, DiagnosesService>();
builder.Services.AddTransient<IVaccinationsService, VaccionationService>();
builder.Services.AddTransient<IAppointmentService, AppointmentService>();
builder.Services.AddTransient<IServiceService, ServiceService>();
builder.Services.AddTransient<IInvoiceService, eVetCare.Services.InvoiceService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddTransient<IRecommendationService, RecommendationService>();
builder.Services.AddTransient<IAuthService, AuthService>();
builder.Services.AddTransient<ISpeciesService, SpeciesService>();
builder.Services.AddTransient<IGendersService, GenderService>();


builder.Services.AddScoped<IAnalyticsService, AnalyticsService>();

builder.Services.AddHostedService<NotificationWorker>();


builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)
        )
    };
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyHeader()
               .AllowAnyMethod();
    });
});

builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.ListenAnyIP(5081); 
});


StripeConfiguration.ApiKey = builder.Configuration["Stripe:SecretKey"];

var app = builder.Build();

app.UseCors("AllowAll");

app.UseStaticFiles();

// Configure the HTTP request pipeline.
 app.UseSwagger();
 app.UseSwaggerUI();


app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();

