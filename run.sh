#!/bin/bash
cd /etc/supervisor/conf.d/

sed -i "s|command=hypercorn -w 1 -b 0.0.0.0:6012 wsgi:app|command=hypercorn -w 1 -b $FLOAPIURL wsgi:app|" /etc/supervisor/conf.d/ftt-ranchimallflo.conf
sed -i "s|window.tokenapiUrl = 'https://ranchimallflo.duckdns.org'|window.tokenapiUrl = '$FLOAPIURL'|" /floscout/index.html

if [ ! -z "$FLOSCOUT_BOOTSTRAP" ] && [ "$(cat /data/floscout-url.txt)" != "$FLOSCOUT_BOOTSTRAP" ]
then
  # download and extract Floscout boostrap
  echo 'Downloading FLOSCOUT Bootstrap...'
  RUNTIME="$(date +%s)"
  curl -L $FLOSCOUT_BOOTSTRAP -o /data/data.zip --progress-bar | tee /dev/null
  RUNTIME="$(($(date +%s)-RUNTIME))"
  echo "FLOSCOUT BOOTSTRAP Download Complete (took ${RUNTIME} seconds)"
  echo 'Extracting Bootstrap...'
  RUNTIME="$(date +%s)"
  upzip /data/data.zip -d /data
  RUNTIME="$(($(date +%s)-RUNTIME))"
  echo "FLOSCOUT Bootstrap Extraction Complete! (took ${RUNTIME} seconds)"
  rm -f /data/data.zip
  echo 'Erased Bootstrap `.zip` file'
  echo "$FLOSCOUT_BOOTSTRAP" > /data/floscout-url.txt
  ls /data
fi

echo "running..."
#supervisord -c /etc/supervisor/conf.d/ftt-ranchimallflo.conf
#./floscout/example
