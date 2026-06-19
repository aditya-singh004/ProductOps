# Risk Engine Service

Java 17 Spring Boot service that accepts sprint or release task data and returns an explainable risk score.

```bash
mvn test
mvn spring-boot:run
```

Endpoint:

```text
POST /api/risk/calculate
```
