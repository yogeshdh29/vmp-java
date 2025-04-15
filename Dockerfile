# Use official Java 17 image
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Copy the built jar
COPY target/*.jar app.jar

# Expose port
EXPOSE 8080

# Set default profile to 'local', overrideable by environment variable
ENV SPRING_PROFILES_ACTIVE=local

# Use ENTRYPOINT with profile support
ENTRYPOINT ["java", "-jar", "app.jar"]
