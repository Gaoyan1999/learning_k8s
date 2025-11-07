# Use the latest official OpenJDK 21 image
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /app

# Copy Java source file into the container
COPY Hello.java .

# Compile the Java file
RUN javac Hello.java

# Command to run the compiled class
CMD ["java", "Hello"]
