#!/bin/bash
cd /etc/supervisor/conf.d/

sed -i "s|window.tokenapiUrl = 'https://ranchimallflo.duckdns.org'|window.tokenapiUrl = '$FLOAPIURL'|" /floscout/index.html
#sed -i "s|command=hypercorn -w 1 -b 0.0.0.0:6012 wsgi:app|command=hypercorn -w 1 -b $FLOAPIURL wsgi:app" /etc/supervisor/conf.d/ftt-ranchimallflo.conf

#cat /floscout/index.html
#cat /etc/supervisor/conf.d/ftt-ranchimallflo.conf

echo "running..."
#supervisord -c /etc/supervisor/conf.d/ftt-ranchimallflo.conf
#./floscout/example