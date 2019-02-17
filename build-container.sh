#!/bin/bash
docker run -d --runtime=nvidia --ipc=host -p $2:22 --name $1 -v <host volume 1>:/root/datasets -v <host volume 2>:/root/projects <your image name>