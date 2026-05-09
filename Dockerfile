# syntax=docker/dockerfile:1.7

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS backend
WORKDIR /src

COPY backend/global.json ./backend/
COPY backend/Directory.Build.props backend/Directory.Packages.props ./backend/
COPY backend/Smolla.Discussion.slnx ./backend/
COPY backend/src/Smolla.Discussion.Host/*.csproj ./backend/src/Smolla.Discussion.Host/

WORKDIR /src/backend
RUN dotnet restore src/Smolla.Discussion.Host/Smolla.Discussion.Host.csproj

WORKDIR /src
COPY backend/src/ ./backend/src/

WORKDIR /src/backend
RUN dotnet publish src/Smolla.Discussion.Host/Smolla.Discussion.Host.csproj \
    -c Release \
    -o /publish \
    --no-restore \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime

ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_RUNNING_IN_CONTAINER=true

WORKDIR /app
COPY --from=backend /publish ./

EXPOSE 8080

USER app
ENTRYPOINT ["dotnet", "Smolla.Discussion.Host.dll"]
