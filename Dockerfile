FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 6200
EXPOSE 6012
LABEL ranchimall="ranchimallfze@gmail.com"

# for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && apt-get -y --no-install-recommends install python3-pip python3-venv git curl unzip supervisor libsecp256k1-dev build-essential make systemd && rm -rf /var/lib/apt/lists/* 

# libssl-dev automake pkg-config libtool libffi-dev libgmp-dev libyaml-cpp-dev libleveldb-dev

# Clone all required git folders
WORKDIR /
RUN git clone https://github.com/ranchimall/pyflo && git clone --branch token-swap https://github.com/ranchimall/flo-token-tracking.git && git clone https://github.com/ranchimall/ranchimallflo-api && git clone https://github.com/ranchimall/floscout.git

# Setup of Flo Token Tracker
WORKDIR /flo-token-tracking
RUN python3 -m venv env && ./env/bin/python3 -m pip install -r requirements.txt && ./env/bin/python3 /pyflo/setup.py install && touch config.ini && touch config.py
RUN if [[ $NETWORK=='test' ]] ; then echo "[DEFAULT]\nNET = testnet\nFLO_CLI_PATH = /usr/local/bin/flo-cli\nSTART_BLOCK = 740400\nFLOSIGHT_NETURL = https://testnet-flosight.duckdns.org/\nTESTNET_FLOSIGHT_SERVER_LIST = https://testnet-flosight.duckdns.org/\nMAINNET_FLOSIGHT_SERVER_LIST = https://flosight.duckdns.org/\nTOKENAPI_SSE_URL = https://ranchimallflo-testnet.duckdns.org\nDATA_PATH=/data\nIGNORE_BLOCK_LIST = 902446\nIGNORE_TRANSACTION_LIST = b4ac4ddb51188b28b39bcb3aa31357d5bfe562c21e8aaf8dde0ec560fc893174" >> /flo-token-tracking/config.ini ; else echo "[DEFAULT]\nNET = mainnet\nFLO_CLI_PATH = /usr/local/bin/flo-cli\nSTART_BLOCK = 3387900\nFLOSIGHT_NETURL = https://flosight.duckdns.org/\nTESTNET_FLOSIGHT_SERVER_LIST = https://testnet-flosight.duckdns.org/\nMAINNET_FLOSIGHT_SERVER_LIST = https://flosight.duckdns.org/\nTOKENAPI_SSE_URL = https://ranchimallflo.duckdns.org\nDATA_PATH=/data\nIGNORE_BLOCK_LIST = 902446\nIGNORE_TRANSACTION_LIST = b4ac4ddb51188b28b39bcb3aa31357d5bfe562c21e8aaf8dde0ec560fc893174" >> /flo-token-tracking/config.ini ; fi
RUN if [[ $NETWORK=='test' ]] ; then echo "committeeAddressList = ['oVwmQnQGtXjRpP7dxJeiRGd5azCrJiB6Ka'] \nsseAPI_url = 'https://ranchimallflo-testnet.duckdns.org/' \nprivKey = 'RG6Dni1fLqeT2TEFbe7RB9tuw53bDPDXp8L4KuvmYkd5JGBam6KJ' " >> /flo-token-tracking/config.py ; else echo "committeeAddressList = ['FRwwCqbP7DN4z5guffzzhCSgpD8Q33hUG8'] \nsseAPI_url = 'https://ranchimallflo.duckdns.org/' \nprivKey = 'RG6Dni1fLqeT2TEFbe7RB9tuw53bDPDXp8L4KuvmYkd5JGBam6KJ' " >> /flo-token-tracking/config.py ; fi

# Setup of RanchimallFlo API
WORKDIR /ranchimallflo-api
RUN python3 -m venv env && ./env/bin/python3 -m pip install --upgrade pip setuptools wheel && ./env/bin/python3 -m pip install -r requirements.txt
RUN touch config.py && echo "dbfolder = '/data' \nsse_pubKey = '02b68a7ba52a499b4cb664033f511a14b0b8b83cd3b2ffcc7c763ceb9e85caabcf' \napiUrl = 'https://flosight.duckdns.org/api/' \napilayerAccesskey = '3abc51aa522420e4e185ac22733b0f30' \nFLO_DATA_DIR = '/home/production/.flo' " >> /ranchimallflo-api/config.py

WORKDIR /pyflo
RUN /ranchimallflo-api/env/bin/python3 setup.py install
RUN /flo-token-tracking/env/bin/python3 setup.py install

# Setup of Floscout
#WORKDIR /floscout
#RUN sed -i "s|window.tokenapiUrl = 'http://0.0.0.0:6012'|window.tokenapiUrl = $FLOAPIURL|" /floscout/index.html

# Supervisor configurations
WORKDIR /etc/supervisor/conf.d/
RUN touch ftt-ranchimallflo.conf
RUN echo "[supervisord] \nnodaemon=true\n[program:flo-token-tracking]\ndirectory=/flo-token-tracking\ncommand=/flo-token-tracking/env/bin/python3 tracktokens_smartcontracts.py\nuser=root\nautostart=true\nautorestart=false\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/flo-token-tracking/flo-token-tracking.err.log\nstdout_logfile=/var/log/flo-token-tracking/flo-token-tracking.out.log\n[program:ranchimallflo-api]\ndirectory=/ranchimallflo-api\ncommand=/ranchimallflo-api/env/bin/hypercorn -w 1 -b 0.0.0.0:6012 wsgi:app\nuser=root\nautostart=true\nautorestart=true\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.err.log \nstdout_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.out.log\n[program:floscout]\ndirectory=/floscout\ncommand=/floscout/example\nuser=root\nautostart=true\nautorestart=false\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/floscout/floscout.err.log\nstdout_logfile=/var/log/floscout/floscout.out.log\n" >> ftt-ranchimallflo.conf
RUN mkdir /var/log/flo-token-tracking && touch /var/log/flo-token-tracking/flo-token-tracking.err.log && touch /var/log/flo-token-tracking/flo-token-tracking.out.log && mkdir /var/log/ranchimallflo-api/ && touch /var/log/ranchimallflo-api/ranchimallflo-api.err.log && touch /var/log/ranchimallflo-api/ranchimallflo-api.out.log && mkdir /var/log/floscout/ && touch /var/log/floscout/floscout.err.log && touch /var/log/floscout/floscout.out.log

RUN mkdir /data 
WORKDIR /
RUN mkdir mongoose-server
COPY mongoose-server/ /mongoose-server
COPY run.sh .
RUN chmod +x run.sh
ENTRYPOINT ["sh","/run.sh"]
