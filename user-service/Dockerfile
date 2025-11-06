FROM openjdk:26-slim

WORKDIR /app

RUN apt -y update && apt -y install curl && \
    useradd --user-group --no-create-home webservice && \
    chown -R webservice:webservice /app

COPY target/*.jar webservice.jar

EXPOSE 8080

USER webservice

ENTRYPOINT ["java", "-jar", "webservice.jar"]
CMD []