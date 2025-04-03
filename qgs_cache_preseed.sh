#!/bin/sh

projects=$(find /data -name '*'${QGS_EXT})

preseed() {
  url=$1
  nr=$2
  echo "- Sending request $nr"
  code=$(curl -o /dev/null -s -w "%{http_code}" "${url}")
  echo "- Request $nr completed with status code $code"
}

if [ -f /preseed_services.txt ]; then
  echo "Reading services names from preseed_services.txt..."
  service_names=$(cat /preseed_services.txt | sed 's|^/ows/||');
elif [ -d /data ]; then
  echo "Scanning /data for projects..."
  service_names=$(find /data -name '*'${QGS_EXT} | sed "s|^/data/||; s|${QGS_EXT}$||")
else
  echo "No service names found. Mount a file to /preseed_services.txt or mount your projects dir to /data."
  exit 0
fi

echo "$service_names" | while IFS= read -r service_name; do
  echo "Processing service ${service_name}"
  url="http://qwc-qgis-server/ows/${service_name}?SERVICE=WMS&REQUEST=GetCapabilities&VERSION=1.3.0"
  echo "- Request URL: ${url}"

  pids=""
  for i in $(seq 1 $FCGI_INSTANCES); do
    preseed "${url}" $i &
    pid=$!
    pids="$pids $pid"
  done

  for pid in $pids; do
      wait $pid
  done

  echo ""
  echo "Sleeping for $SLEEP_INTERVAL seconds..."
  sleep $SLEEP_INTERVAL
  echo ""
done
echo "Done!"
