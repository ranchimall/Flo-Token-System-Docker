FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 6200

LABEL ranchimall="ranchimallfze@gmail.com"

# CMD { "echo", "Ranchi Mall" }

# for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update
RUN apt-get -y install python3-pip
RUN apt-get -y install git
RUN apt-get -y install python-chardet python3.9 python3.9-venv
RUN apt-get -y install libsecp256k1-dev libssl-dev build-essential automake pkg-config libtool libffi-dev libgmp-dev libyaml-cpp-dev
RUN apt-get install supervisor
RUN echo_supervisord_conf
RUN echo_supervisord_conf > /etc/supervisord.conf

# Installation of Pybtc, currently named as Pyflo 
WORKDIR ../
RUN git clone https://github.com/ranchimall/pyflo
WORKDIR pyflo
RUN apt-get install -y pkg-config
RUN python3 setup.py install
WORKDIR ../

# Setup of Flo Token Tracker
RUN git clone https://github.com/vivekteega/ftt-docker
RUN apt install python3.8-venv 
WORKDIR ftt-docker
#RUN python3.9 -m venv ftt
#RUN . ftt/bin/activate
RUN python3 -m pip install chardet
RUN python3 -m pip install arrow
RUN python3 -m pip install socketio
RUN python3 -m pip install requests
RUN python3 -m venv env
RUN sed -i "s|chardet==4.0.0|chardet|g" /ftt-docker/requirements.txt
RUN touch config.ini
RUN echo "[DEFAULT] \n\
    NET = testnet \n\
    FLO_CLI_PATH = /usr/local/bin/flo-cli \n\
    START_BLOCK = 740400" >> /ftt-docker/config.ini

RUN touch config.py
RUN echo "committeeAddressList = ['oVwmQnQGtXjRpP7dxJeiRGd5azCrJiB6Ka'] \n\
    sseAPI_url = 'https://ranchimallflo-testnet.duckdns.org/' \n\
    privKey = 'RG6Dni1fLqeT2TEFbe7RB9tuw53bDPDXp8L4KuvmYkd5JGBam6KJ' " >> /ftt-docker/config.py


# Setup of RanchimallFlo API
RUN git clone https://github.com/ranchimall/ranchimallflo-api
WORKDIR ranchimallflo-api
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN python3 -m venv env
RUN python3 -m pip install -r requirements.txt
RUN pip3 install apscheduler
RUN touch config.py
RUN echo "dbfolder = '/home/production/dev/shivam/ranchimallflo-api' \n\
    sse_pubKey = '02b68a7ba52a499b4cb664033f511a14b0b8b83cd3b2ffcc7c763ceb9e85caabcf' \n\
    apiUrl = 'https://flosight.duckdns.org/api/' \n\
    apilayerAccesskey = '3abc51aa522420e4e185ac22733b0f30' \n\
    FLO_DATA_DIR = '/home/production/.flo' " >> /config.py


# Setup of Floscout
RUN git clone https://github.com/ranchimall/floscout.git
WORKDIR floscout
RUN git clone https://github.com/Dbhardwaj99/mongoose-server-files.git
WORKDIR mongoose-server-files
RUN mv example ~/floscout
WORKDIR ../
WORKDIR ../

# setup of mongoose server
# RUN git clone https://github.com/cesanta/mongoose.git
# WORKDIR mongoose
# RUN sudo simplest_web_server.c
# WORKDIR ../

# Supervisor configurations
## Flo token tracking configuration
## Ranchimallflo configuration
WORKDIR /etc/supervisor/conf.d/
RUN touch ftt-ranchimallflo.conf
RUN echo "[supervisord] \n\
    nodaemon=true\n\
    [program:ftt-docker]\n\
    directory=ftt-docker\n\
    command=tracktokens-smartcontracts.py\n\
    user=root\n\
    autostart=true\n\
    autorestart=true\n\
    stopasgroup=true\n\
    killasgroup=true\n\
    stderr_logfile=/var/log/flo-token-tracking/flo-token-tracking.err.log\n\
    stdout_logfile=/var/log/flo-token-tracking/flo-token-tracking.out.log\n\
    [program:ranchimallflo-api]\n\
    directory=/ranchimallflo-api\n\
    command=/ranchimallflo-api/env/bin/hypercorn -w 1 -b 0.0.0.0:5009 wsgi:app\n\
    user=root\n\
    autostart=true\n\
    autorestart=true\n\
    stopasgroup=true\n\
    killasgroup=true\n\
    stderr_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.err.log \n\
    stdout_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.out.log" >> ftt-ranchimallflo.conf
RUN mkdir /var/log/flo-token-tracking
RUN touch /var/log/flo-token-tracking/flo-token-tracking.err.log
RUN touch /var/log/flo-token-tracking/flo-token-tracking.out.log
RUN mkdir /var/log/ranchimallflo-api/
RUN touch /var/log/ranchimallflo-api/ranchimallflo-api.err.log
RUN touch /var/log/ranchimallflo-api/ranchimallflo-api.out.log

RUN service supervisor restart