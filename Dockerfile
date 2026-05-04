FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart compile exe lib/server.dart -o server

FROM debian:stable-slim

WORKDIR /app

COPY --from=build /app/server /app/server

RUN chmod +x /app/server

EXPOSE 8080

CMD ["/app/server"]