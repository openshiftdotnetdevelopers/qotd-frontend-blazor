# 1. Get the "build" base image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build



# 2. Create a working directory and build the solution
WORKDIR /src
COPY qotd-frontend-blazor.csproj .
COPY /wwwroot/appsettings.json .
RUN dotnet restore qotd-frontend-blazor.csproj
COPY . .
RUN dotnet build qotd-frontend-blazor.csproj -c Release -o /app/build



# 3. Prepare the intermediate "publish" image
FROM build AS publish
RUN dotnet publish qotd-frontend-blazor.csproj -c Release -o /app/publish



# 4. Get the nginx image and move the pieces necessary
FROM docker.io/nginx AS final
WORKDIR /usr/share/nginx/html
COPY --from=build /src/appsettings.json .
COPY --from=build /src/container_run.sh .
COPY --from=publish /app/publish/wwwroot .
COPY nginx.conf /etc/nginx/nginx.conf



# 5. Some permissions need to be set because things
#    will be changed at rumtime
RUN chown -R 1001:0 /var/cache/nginx && chmod -R ug+rwx /var/cache/nginx && chown -R 1001:0 /var/run
RUN chmod +x ./container_run.sh
RUN chmod 777 ./



# 6. Running on port 5050; this agrees with the port in the nginx.conf file
USER 1001
EXPOSE 5050



# 7. Call the startup command, which modifies the appsettings.json
#    file before starting the image
CMD ./container_run.sh