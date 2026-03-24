# Use Dart stable image
FROM dart:stable

# Set working directory
WORKDIR /app

# Copy pubspec files and fetch dependencies
COPY pubspec.* ./
RUN dart pub get --offline

# Copy the rest of the project
COPY . .

# Expose the port your server listens on
EXPOSE 8080

# Environment variables can also be set in Andasy CLI or andasy.hcl
# Start the Dart server
CMD ["dart", "run", "lib/server.dart"]