#!/bin/bash
cd /etc/supervisor/conf.d/

echo "running..."
supervisord -c /etc/supervisor/conf.d/ftt-ranchimallflo.conf