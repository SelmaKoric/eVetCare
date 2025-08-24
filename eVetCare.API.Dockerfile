FROM mcr.microsoft.com/dotnet/sdk:9.0.301 AS build
WORKDIR /src

COPY eVetCare.sln ./
COPY eVetCare/eVetCare.API.csproj eVetCare/
COPY eVetCare.Model/eVetCare.Model.csproj eVetCare.Model/
COPY eVetCare.Services/eVetCare.Services.csproj eVetCare.Services/
COPY eVetCare.Notifications/eVetCare.Notifications.csproj eVetCare.Notifications/

RUN dotnet restore eVetCare.sln

# Copy source code for all projects
COPY eVetCare/ eVetCare/
COPY eVetCare.Model/ eVetCare.Model/
COPY eVetCare.Services/ eVetCare.Services/
COPY eVetCare.Notifications/ eVetCare.Notifications/

# Remove conflicting appsettings files from Notifications project
RUN rm -f eVetCare.Notifications/appsettings*.json

RUN dotnet publish eVetCare/eVetCare.API.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "eVetCare.API.dll"]
