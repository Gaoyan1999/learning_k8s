FROM openjdk:8-jdk-slim
WORKDIR /app
COPY App.java .

# Install Maven to download dependency
RUN apt-get update && apt-get install -y maven

# Download MySQL connector
RUN mvn dependency:get -DgroupId=mysql -DartifactId=mysql-connector-java -Dversion=8.0.33 -Ddest=./mysql-connector-java.jar

# Compile
RUN javac -cp .:mysql-connector-java.jar App.java

# COPY wait-for-db.sh .
CMD ["java", "-cp", ".:mysql-connector-java.jar", "App"]
