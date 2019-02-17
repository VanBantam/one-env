#!/bin/bash

# $1 the local ip of the container
# $2 the host port that container port would be forwarded to.  So for example 8888.
# Note the third argument is the ssh port of the container
#
#ssh -N -f -L $2:localhost:8888 root@$1 -p $3
ssh -N -f -L $1:localhost:8888 container-1 -p $2