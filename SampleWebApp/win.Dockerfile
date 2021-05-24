FROM mcr.microsoft.com/dotnet/sdk:3.1-nanoserver-2004 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:3.1-nanoserver-2004
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "samplewebapp.dll"]