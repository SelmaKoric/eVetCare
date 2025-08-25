using eVetCare.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

public class Ib170054ContextFactory : IDesignTimeDbContextFactory<Ib170054Context>
{
    public Ib170054Context CreateDbContext(string[] args)
    {
        var cfg = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", true)
            .AddJsonFile("appsettings.Development.json", true)
            .AddEnvironmentVariables()
            .Build();

        var cs =
            cfg.GetConnectionString("DefaultConnection") ??
            cfg["ConnectionStrings:DefaultConnection"] ??
            "Server=localhost,1433;Database=EVetCare;User ID=sa;Password=Your_password123;TrustServerCertificate=True;Encrypt=False;MultipleActiveResultSets=true";

        var opts = new DbContextOptionsBuilder<Ib170054Context>()
            .UseSqlServer(cs)
            .Options;

        return new Ib170054Context(opts);
    }
}
