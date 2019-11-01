FROM mcr.microsoft.com/dotnet/core/aspnet:2.1
WORKDIR /app
COPY ./out .
ENTRYPOINT ["dotnet", "samplewebapp.dll"]