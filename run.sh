#!/bin/bash

exec python3 /ftt-docker/tracktokens-smartcontracts.py &
exec python3 /ranchimallflo-api/hypercorn -w 1 -b 0.0.0.0:5009 wsgi:app