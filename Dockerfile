FROM alpine:3.21

RUN apk add --no-cache curl cronie postgresql-client

WORKDIR /app
COPY qgs_cache_preseed.sh /app/qgs_cache_preseed.sh
RUN chmod +x /app/qgs_cache_preseed.sh

# Default cron schedule: every day at 03:00
ENV CRON_SCHEDULE="0 3 * * *"
# Whether to execute the script directly on startup before running cron
ENV EXECUTE_ON_STARTUP=0
# The QGIS project file extension to look for
ENV QGS_EXT=.qgs
# The number of FCGI instances (i.e. the number if simultaneous requests to send)
ENV FCGI_INSTANCES=10
# The sleep interval in seconds between sending requests
ENV SLEEP_INTERVAL=1

# The default URL of the QGIS server to send requests to
ENV DEFAULT_QGIS_SERVER_URL="http://qwc-qgis-server/ows/"

# Connection URL for configuration database to read QGIS project files
ENV PGSERVICEFILE="/srv/pg_service.conf"
ENV CONFIG_DB_URL="postgresql:///?service=qgisprojects"
# The name of the DB schema which stores the project files in a table 'qgis_projects'.
ENV PG_DB_SCHEMA="qwc_config"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
