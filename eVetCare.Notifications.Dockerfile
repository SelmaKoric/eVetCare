FROM mcr.microsoft.com/dotnet/sdk:9.0.301 AS build
WORKDIR /src

COPY eVetCare.Model/eVetCare.Model.csproj eVetCare.Model/
COPY eVetCare.Services/eVetCare.Services.csproj eVetCare.Services/
COPY eVetCare.Notifications/eVetCare.Notifications.csproj eVetCare.Notifications/

RUN dotnet restore eVetCare.Model/eVetCare.Model.csproj
RUN dotnet restore eVetCare.Services/eVetCare.Services.csproj
RUN dotnet restore eVetCare.Notifications/eVetCare.Notifications.csproj

COPY . .

RUN dotnet publish ./eVetCare.Notifications/eVetCare.Notifications.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/runtime:9.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet","eVetCare.Notifications.dll"]
