#!/bin/bash
docker network connect $1 $2 &&
docker network inspect $1