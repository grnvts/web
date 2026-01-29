FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw -q -B dependency:go-offline
COPY src src
RUN ./mvnw -q -B package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
ENV JAVA_OPTS=""
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8501
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
