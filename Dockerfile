
## Here is the builder image:
FROM bellsoft/liberica-runtime-container:jdk-17-stream-musl as builder

WORKDIR /home/app
COPY . .
RUN ./mvnw clean package -DskipTests

## Here is the base image:
FROM bellsoft/liberica-runtime-container:jdk-17-stream-musl AS optimizer

WORKDIR /home/app
COPY --from=builder /home/app/target/*.jar petclinic.jar
RUN java -Djarmode=layertools -jar petclinic.jar extract

## Here is the final image:
FROM bellsoft/liberica-runtime-container:jre-17-stream-musl

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
COPY --from=optimizer /home/app/dependencies/ ./
COPY --from=optimizer /home/app/spring-boot-loader/ ./
COPY --from=optimizer /home/app/snapshot-dependencies/ ./
COPY --from=optimizer /home/app/application/ ./