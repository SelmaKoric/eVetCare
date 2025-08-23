using eVetCare.Model;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;

public class RecommendationService : IRecommendationService
{
    private readonly MLContext _mlContext;
    private readonly EVetCareContext _context;

    public RecommendationService(EVetCareContext context)
    {
        _mlContext = new MLContext();
        _context = context;
    }

    public void GenerateRecommendationsForPet(int petId)
    {
        var ownerId = _context.Pets
            .Where(p => p.PetId == petId)
            .Select(p => p.OwnerId)
            .FirstOrDefault();

        // 1. Load training data
        var trainingData = _context.InvoiceItems
            .Join(_context.Invoices, ii => ii.InvoiceId, i => i.InvoiceId, (ii, i) => new { i.AppointmentId, ii.ServiceId })
            .Join(_context.Appointments, x => x.AppointmentId, a => a.AppointmentId, (x, a) => new { a.Pet.OwnerId, x.ServiceId })
            .Select(x => new ServiceRating
            {
                OwnerId = x.OwnerId,
                ServiceId = x.ServiceId,
                Label = 1f
            })
            .ToList();

        var dataView = _mlContext.Data.LoadFromEnumerable(trainingData);

        // 2. Create pipeline
        var pipeline = _mlContext.Transforms.Conversion
            .MapValueToKey("OwnerIdEncoded", nameof(ServiceRating.OwnerId))
            .Append(_mlContext.Transforms.Conversion.MapValueToKey("ServiceIdEncoded", nameof(ServiceRating.ServiceId)))
            .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(new MatrixFactorizationTrainer.Options
            {
                MatrixRowIndexColumnName = "OwnerIdEncoded",
                MatrixColumnIndexColumnName = "ServiceIdEncoded",
                LabelColumnName = "Label",
                NumberOfIterations = 20,
                ApproximationRank = 100
            }));

        // 3. Train the model
        var model = pipeline.Fit(dataView);

        // 4. Make predictions
        var predictionEngine = _mlContext.Model.CreatePredictionEngine<ServiceRating, ServiceScore>(model);

        var allServiceIds = _context.Services.Select(s => s.ServiceId).ToList();

        var predictions = allServiceIds
            .Select(sid => new
            {
                ServiceId = sid,
                Score = predictionEngine.Predict(new ServiceRating { OwnerId = ownerId, ServiceId = sid }).Score
            })
            .OrderByDescending(x => x.Score)
            .Take(3)
            .ToList();

        // 5. Save to DB
        var recommendedServices = _context.Services
            .Where(s => predictions.Select(p => p.ServiceId).Contains(s.ServiceId))
            .Select(s => s.Name)
            .ToList();

        var content = "Recommended services: " + string.Join(", ", recommendedServices);

        _context.Recommendations.Add(new Recommendation
        {
            PetId = petId,
            Content = content,
            CreatedAt = DateTime.Now
        });

        _context.SaveChanges();
    }

    public RecommendationModel? GetRecommendationsForPet(int petId)
    {
        var rec = _context.Recommendations
                    .Where(r => r.PetId == petId)
                    .OrderByDescending(r => r.CreatedAt)
                    .FirstOrDefault()
                    ?? _context.Recommendations
                        .Where(r => r.PetId == petId)
                        .OrderByDescending(r => r.CreatedAt)
                        .FirstOrDefault();

        if (rec == null)
            return null;

        return new RecommendationModel
        {
            Content = rec.Content,
            CreatedAt = rec.CreatedAt
        };
    }
}