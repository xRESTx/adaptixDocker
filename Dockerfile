FROM eclipse-temurin:17-jre-jammy

RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client redis-tools && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. wrapper script (no external files needed)
RUN printf '#!/bin/bash\n\
until pg_isready -h postgres -p 5432 -U ${POSTGRES_USER:-postgres}; do sleep 1; done\n\
until redis-cli -h redis -p 6379 ping; do sleep 1; done\n\
exec java -XX:+UseContainerSupport -Xmx1g \
     -Dspring.config.location=file:/app/config/app.properties \
     -jar /app/adaptix_bot.jar\n' > /entry.sh && chmod +x /entry.sh

# 2. copy your jar
COPY adaptix_bot.jar app.jar

ENTRYPOINT ["/entry.sh"]