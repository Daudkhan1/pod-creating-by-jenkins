FROM python:3.9-slim
WORKDIR /app
COPY . .
CMD ["python", "python.py"]



# FROM openjdk:8-jdk

# WORKDIR /opt
# COPY target/my-app-1.0-SNAPSHOT.jar /opt/my-app-1.0-SNAPSHOT.jar

# CMD ["java", "-jar", "my-app-1.0-SNAPSHOT.jar"]

