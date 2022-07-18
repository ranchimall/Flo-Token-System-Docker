FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 6200
EXPOSE 6012
LABEL ranchimall="ranchimallfze@gmail.com"

# for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update
RUN apt-get -y install python3-pip nano git curl python-chardet python3.9 python3.9-venv python3.8-venv unzip 
RUN apt-get -y install libsecp256k1-dev libssl-dev build-essential automake pkg-config libtool libffi-dev libgmp-dev libyaml-cpp-dev pkg-config
RUN python3 -m pip install supervisor

# Installation of Pybtc, currently named as Pyflo 
WORKDIR ../
RUN git clone https://github.com/ranchimall/pyflo
RUN cd pyflo && python3 setup.py install

# Setup of Flo Token Tracker
RUN git clone --branch token-swap https://github.com/ranchimall/flo-token-tracking.git 
WORKDIR flo-token-tracking
RUN sed -i "s|chardet==4.0.0|chardet|g" /flo-token-tracking/requirements.txt
RUN python3 -m venv env
RUN python3 -m pip install chardet arrow sqlalchemy python-socketio requests
RUN touch config.ini
RUN touch config.py


RUN if [[ $NETWROKK=='test' ]] ; then echo "[DEFAULT]\nNET = testnet\nFLO_CLI_PATH = /usr/local/bin/flo-cli\nSTART_BLOCK = 740400\nFLOSIGHT_NETURL = http://0.0.0.0:9000/\nTESTNET_FLOSIGHT_SERVER_LIST = http://0.0.0.0:9000/, https://testnet-flosight.duckdns.org/\nMAINNET_FLOSIGHT_SERVER_LIST = http://0.0.0.0:9495/, https://flosight.duckdns.org/\nTOKENAPI_SSE_URL = https://ranchimallflo-testnet.duckdns.org\nDATA_PATH=/data\nIGNORE_BLOCK_LIST = 902446\nIGNORE_TRANSACTION_LIST = b4ac4ddb51188b28b39bcb3aa31357d5bfe562c21e8aaf8dde0ec560fc893174" >> /flo-token-tracking/config.ini ; else echo "[DEFAULT]\nNET = testnet\nFLO_CLI_PATH = /usr/local/bin/flo-cli\nSTART_BLOCK = 740400\nFLOSIGHT_NETURL = http://0.0.0.0:9000/\nTESTNET_FLOSIGHT_SERVER_LIST = http://0.0.0.0:9000/, https://testnet-flosight.duckdns.org/\nMAINNET_FLOSIGHT_SERVER_LIST = http://0.0.0.0:9495/, https://flosight.duckdns.org/\nTOKENAPI_SSE_URL = https://ranchimallflo-testnet.duckdns.org\nDATA_PATH=/data\nIGNORE_BLOCK_LIST = 902446\nIGNORE_TRANSACTION_LIST = b4ac4ddb51188b28b39bcb3aa31357d5bfe562c21e8aaf8dde0ec560fc893174" >> /flo-token-tracking/config.ini ; fi
RUN if [[ $NETWROKK=='test' ]] ; then echo "committeeAddressList = ['oVwmQnQGtXjRpP7dxJeiRGd5azCrJiB6Ka'] \nsseAPI_url = 'https://ranchimallflo-testnet.duckdns.org/' \nprivKey = 'RG6Dni1fLqeT2TEFbe7RB9tuw53bDPDXp8L4KuvmYkd5JGBam6KJ' " >> /flo-token-tracking/config.py ; else echo "committeeAddressList = ['oVwmQnQGtXjRpP7dxJeiRGd5azCrJiB6Ka'] \nsseAPI_url = 'https://ranchimallflo-testnet.duckdns.org/' \nprivKey = 'RG6Dni1fLqeT2TEFbe7RB9tuw53bDPDXp8L4KuvmYkd5JGBam6KJ' " >> /flo-token-tracking/config.py ; fi

# Setup of RanchimallFlo API
WORKDIR ../
RUN git clone https://github.com/ranchimall/ranchimallflo-api
WORKDIR ranchimallflo-api
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN python3 -m venv env
RUN python3 -m pip install -r requirements.txt
RUN pip3 install apscheduler
RUN touch config.py
RUN echo "dbfolder = '/data' \nsse_pubKey = '02b68a7ba52a499b4cb664033f511a14b0b8b83cd3b2ffcc7c763ceb9e85caabcf' \napiUrl = 'https://flosight.duckdns.org/api/' \napilayerAccesskey = '3abc51aa522420e4e185ac22733b0f30' \nFLO_DATA_DIR = '/home/production/.flo' " >> /ranchimallflo-api/config.py


# Setup of Floscout
WORKDIR ../
RUN git clone https://github.com/ranchimall/floscout.git
WORKDIR floscout
RUN sed -i "s|window.tokenapiUrl = 'http://0.0.0.0:6012'|window.tokenapiUrl = $FLOAPIURL|" /floscout/index.html
WORKDIR ../

##clientside changes
#COPY flo.sh .
#RUN chmod +x flo.sh
#RUN #flo.sh

# Supervisor configurations
WORKDIR /etc/supervisor/conf.d/
RUN touch ftt-ranchimallflo.conf
RUN echo "[supervisord] \nnodaemon=true\n[program:flo-token-tracking]\ndirectory=/flo-token-tracking\ncommand=/usr/bin/python3 tracktokens_smartcontracts.py\nuser=root\nautostart=true\nautorestart=false\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/flo-token-tracking/flo-token-tracking.err.log\nstdout_logfile=/var/log/flo-token-tracking/flo-token-tracking.out.log\n[program:ranchimallflo-api]\ndirectory=/ranchimallflo-api\ncommand=/usr/local/bin/hypercorn -w 1 -b 0.0.0.0:6012 wsgi:app\nuser=root\nautostart=true\nautorestart=true\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.err.log \nstdout_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.out.log\n[program:floscout]\ndirectory=/floscout\ncommand=/floscout/example\nuser=root\nautostart=true\nautorestart=false\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/floscout/floscout.err.log\nstdout_logfile=/var/log/floscout/floscout.out.log" >> ftt-ranchimallflo.conf
RUN mkdir /var/log/flo-token-tracking
RUN touch /var/log/flo-token-tracking/flo-token-tracking.err.log
RUN touch /var/log/flo-token-tracking/flo-token-tracking.out.log
RUN mkdir /var/log/ranchimallflo-api/
RUN touch /var/log/ranchimallflo-api/ranchimallflo-api.err.log
RUN touch /var/log/ranchimallflo-api/ranchimallflo-api.out.log
RUN mkdir /var/log/floscout/
RUN touch /var/log/floscout/floscout.err.log
RUN touch /var/log/floscout/floscout.out.log


RUN mkdir /data 
WORKDIR /
RUN mkdir mongoose-server
COPY mongoose-server/ /mongoose-server
COPY run.sh .
RUN chmod +x run.sh
ENTRYPOINT ["sh","/run.sh"]
