# FLO Token-Smart Contract System Docker 

Docker resources to build components required for FLO Token-Smart Contract system, all at one place! 

## Why do I need this?

FLO Token-Smart Contract system consists of three apps working together 
* FLO Token & Smart Contract tracking scripts (Python)
* RanchiMall FLO API (Python-Flask)
* Floscout Token & Smart Contract explorer (JavaScript)

RanchiMall wants to made things easy for you by packing all the three systems together, so you can get started using out system for your Dapps :) 

## How do I use this?

Clone the repository and build the docker image by the following command

```
sudo docker build .
```

Crete a docker volume

```
docker volume inspect ranchimall-flo-volume
```

Run the docker container with exposing all the port and mounting the volume

```
docker run -it -p 3023:3023 -p 6200:6200 -p 6012:6012 -v ranchimall-flo-volume --env NETWORKK='test' --env FLOAPIURL="0.0.0.0:3023" <IMAGE-ID>
```

To Check if FLO-API is running

```
http://0.0.0.0:5009/api/v1.0/getSystemData
```

To Check if FLOSCOUT is running

```
http://0.0.0.0:4256
```

## Development of the docker commands for regular Floscout on Docker

```

docker volume create floscout

docker run -d --name=floscout \
    -p 6200:6200 -p 6012:6012 \
    -v floscout:/data \
    -e NETWORK=mainnet \
    -e FLOSCOUT_BOOTSTRAP=http://ranchimall-stevejobs.duckdns.org:3847/data.zip \
    ranchimallfze/floscout:1.0.0

docker logs -f floscout

```

## FLOSCOUT BOOTSTRAP CODE (To be removed after code is incorporated)

```
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
```

