# Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy source code
COPY . .

# Generate code
RUN dart run build_runner build --delete-conflicting-outputs

# Build the executable
RUN dart compile exe bin/server.dart -o bin/server

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled binary
COPY --from=build /app/bin/server /app/bin/server

# Create data directory
RUN mkdir -p /app/data

# Set environment variables
ENV PORT=8080
ENV HOST=0.0.0.0
ENV DATABASE_PATH=/app/data/layers.db

EXPOSE 8080

CMD ["/app/bin/server"]
