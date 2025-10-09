FROM maven AS build

WORKDIR /build

COPY . .

RUN mvn clean package -DskipTests

FROM openjdk:26-jdk-slim

WORKDIR /app

RUN groupadd -r webservice && \
    useradd -r webservice -g webservice && \
    chown -R webservice:webservice /app

COPY --from=build /build/target/*.jar webservice.jar

EXPOSE 8080

USER webservice

ENTRYPOINT ["java","-jar","webservice.jar"]
CMD []