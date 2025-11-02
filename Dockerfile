FROM eclipse-temurin:17-jre-jammy

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-client \
        redis-tools && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. копируем ваш jar и переименовываем в app.jar
COPY adaptix_bot.jar app.jar

# 2. создаём стартовый скрипт (внутри образа)
RUN printf '#!/bin/bash\n\
echo "Waiting for Postgres..."\n\
until pg_isready -h postgres -p 5432 -U "${POSTGRES_USER:-postgres}" >/dev/null 2>&1; do sleep 1; done\n\
echo "Waiting for Redis..."\n\
until redis-cli -h redis -p 6379 ping >/dev/null 2>&1; do sleep 1; done\n\
echo "Starting bot..."\n\
exec java -XX:+UseContainerSupport -Xmx1g \
     -Dspring.config.location=file:/app/config/app.properties \
     -jar /app/app.jar\n' > /entry.sh && chmod +x /entry.sh

ENTRYPOINT ["/entry.sh"]