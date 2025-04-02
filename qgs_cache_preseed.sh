#!/bin/sh

projects=$(find /data -name '*'${QGS_EXT})

preseed() {
  service_name=$1
  nr=$2
  echo "- Sending request $nr"
  code=$(curl -o /dev/null -s -w "%{http_code}" "http://qwc-qgis-server/ows/${service_name}?SERVICE=WMS&REQUEST=GetCapabilities&VERSION=1.3.0")
  echo "- Request $nr completed with status code $code"
}


find /data -name '*'${QGS_EXT} -print0 | while IFS= read -r -d $'\0' file; do
  echo "Processing project $file"
  service_name=$(echo $file | sed 's|^\/data/||' | sed "s|$QGS_EXT||")
  echo "- Service name is ${service_name}"

  pids=""
  for i in $(seq 1 $FCGI_INSTANCES); do
    preseed "${service_name}" $i &
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
