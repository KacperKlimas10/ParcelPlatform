FROM openjdk:26-jdk-slim

WORKDIR /app

RUN groupadd -r webservice && \
    useradd -r webservice -g webservice && \
    chown -R webservice:webservice /app

COPY target/*.jar webservice.jar

EXPOSE 8080

USER webservice

ENTRYPOINT ["java","-jar","webservice.jar"]
CMD []