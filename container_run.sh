# This script will replace the value in the files BEFORE starting nginx.
# By replacing the value with the contents of the environment variable,
#   we are able to specify the qotd webapi URL at runtime.
# E.g. podman run -e ERROR_THE_API_URL_HAS_NOT_BEEN_SET="https://foo/bar" quay.io/rhdevelopers/qotd-frontend-blazor:latest

sed -i "s|ERROR_THE_API_URL_HAS_NOT_BEEN_SET|$API_URL|g" ./appsettings.json
nginx -g "daemon off;"