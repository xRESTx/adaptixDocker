FROM eclipse-temurin:17-jre-jammy

RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY wait-for-it.sh /usr/local/bin/
COPY adaptix_bot.jar app.jar

RUN chmod +x /usr/local/bin/wait-for-it.sh

# ждём пока поднимутся postgres:5432 и redis:6379, потом стартуем
ENTRYPOINT ["wait-for-it.sh", "postgres:5432", "--timeout=60", "--strict", "--", \
            "wait-for-it.sh", "redis:6379", "--timeout=30", "--strict", "--"]
CMD ["java", "-XX:+UseContainerSupport", "-Xmx1g", "-jar", "app.jar"]