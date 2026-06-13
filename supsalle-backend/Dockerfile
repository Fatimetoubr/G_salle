# ===== Etape 1 : Build avec Maven =====
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# ===== Etape 2 : Image d'execution legere =====
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/supsalle-backend-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
