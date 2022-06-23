#!/bin/bash
#sed -i "s|window.tokenapiUrl = 'http://0.0.0.0:6012'|window.tokenapiUrl = '$FLOAPIURL'|" /floscout/index.html
cd /etc/supervisor/conf.d/

echo "running..."
supervisord -c /etc/supervisor/conf.d/ftt-ranchimallflo.conf
#./floscout/example