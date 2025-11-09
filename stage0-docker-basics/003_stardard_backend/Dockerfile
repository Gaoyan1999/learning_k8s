# Build stage
FROM gradle:8-jdk21 AS build
WORKDIR /app
# Copy Gradle files
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
# Copy source code
COPY src ./src
# Build application
RUN gradle build -x test

# Run stage
FROM openjdk:21-jdk-slim
WORKDIR /app
# Copy built JAR from build stage
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

