# FLO Token-Smart Contract System Docker 

Docker resources to build components required for FLO Token-Smart Contract system, all at one place! 

## Why do I need this?

FLO Token-Smart Contract system consists of three apps working together 
* FLO Token & Smart Contract tracking scripts (Python)
* RanchiMall FLO API (Python-Flask)
* Floscout Token & Smart Contract explorer (JavaScript)

RanchiMall wants to made things easy for you by packing all the three systems together, so you can get started using out system for your Dapps :) 

## How do I use this?

Clone the repository and Build the docker image by the following command

```
sudo docker build .
```

Run the docker container with exposing all the port and mounting the volume

```
docker run -d -p 4256:4256 -p 6012:6012 <IMAGE-ID>
```

To Check if FLO-API is running

```
0.0.0.0:6012/api/v1.0/getSystemData
```
