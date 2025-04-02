#!/bin/sh
mkdir -p $HOME/.cache

# Wait for qwc-qgis-server
while true; do
  echo -n "Waiting for qwc-qgis-server"
  status_code=$(curl -o /dev/null -s -w "%{http_code}" http://qwc-qgis-server/ows)
  if [ "$status_code" -eq 000 ]; then
    echo -n "."
    sleep 1
  else
    echo " Online!"
    break
  fi
done

if [ ${EXECUTE_ON_STARTUP:-0} -eq 1 ]; then
  /app/qgs_cache_preseed.sh
fi

# Setup cron job
cat > $HOME/.cron_env <<EOF
export QGS_EXT=.qgs
export FCGI_INSTANCES=10
export SLEEP_INTERVAL=1
EOF
echo "$CRON_SCHEDULE . $HOME/.cron_env; /app/qgs_cache_preseed.sh >/proc/1/fd/1 2>/proc/1/fd/2" | crontab -

echo "Starting cron..."
exec crond -f
