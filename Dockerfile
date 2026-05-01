FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart compile exe lib/server.dart -o server

FROM debian:stable-slim

WORKDIR /app

COPY --from=build /app/server server

EXPOSE 8081

CMD ["./server"]