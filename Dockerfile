FROM mcr.microsoft.com/dotnet/runtime:7.0-alpine AS base
RUN addgroup -S appuser --gid 1337 && adduser -S appuser -G appuser --uid 1337
WORKDIR /app
RUN chown -R appuser:appuser /app

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

WORKDIR /src
COPY ["HelloAKS.csproj", "./"]
RUN dotnet restore "HelloAKS.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "HelloAKS.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HelloAKS.csproj" -c Release -o /app/publish

FROM base AS final
COPY --from=publish /app/publish .

USER appuser
ENTRYPOINT ["dotnet", "HelloAKS.dll"]