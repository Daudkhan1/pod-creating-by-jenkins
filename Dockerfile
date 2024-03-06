# FROM java:8
# WORKDIR /opt
# ADD target/my-app-1.0-SNAPSHOT.jar /opt

# CMD ["java", "-jar", "opt/my-app-1.0-SNAPSHOT.jar"]




FROM openjdk:8-jdk

WORKDIR /opt
COPY target/my-app-1.0-SNAPSHOT.jar /opt/my-app-1.0-SNAPSHOT.jar

CMD ["java", "-jar", "my-app-1.0-SNAPSHOT.jar"]

