# one-env
The one deep learning docker environment to rule them all. <br>
<br>
This environment is intended for performing development work on your remote computing badass machine.  It's not intended for any sort of production environment.  One of the goals is to keep that remote computing badass machine free from the clutter that comes with installing data science and deeplearning packages. <br>
A bit of opinion here but I have had fewer problems working in a docker container than I have had working in virtual / conda environments.  <br>
Why am I running sshd rather than just running Jupyter?  I found that despite my best efforts at planning I still need to modify the contents of the container from time to time and I don't want to build a new container.  Also I really don't like the terminal interface in Jupyter.

## What's in here...
1. Nvidia base image cuda 9.2 cudnn 7 ubuntu 16.04
2. Python 3.6.8
3. Anaconda and the standard data science python packages
4. Caffe 2
5. OpenCV 4
6. FastAI 1.0
7. Detectron
8. COCO api
9. TensorFlow GPU 1.12
10. sshd

## How to use it
### Requirements
1. Linux system with a gpu, cuda, nvidia driver, docker, and nvidia docker runtime environment.
2. Verification that your system can run access the gpu from a container.  Nvidia has a container for this specific purpose.
3. A docker network.
4. Port forward from remote to local.  Port forward from container to remote.  This is for running jupyter on the container from local.
5. Pull nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04 image to your local docker repo.

### Before you build...
1. Change the number of workers for making OpenCV4.  Yes going from 10 to 30 makes a big difference in build times.  My 1950x at 30 is about 40 minutes faster than my 8700k.  Search for 'RUN make -j30'
2. Not everyone wants their jupyter server to be without a password.  Go to the 'FINAL SETUP' section.
3. 'FINAL SETUP' also has the password for sshd.
4. You may want to change the volumes being exposed.  This can be changed at the end of the Dockerfile.
5. Modify the included shell scripts with your details.  They're there to make my life easier and now yours as well. 

### Building & Running
1. Navigate to your directory and `docker build -t <your name> .` Go get a cup of coffee. 
2. Build the container.  `docker run -d --runtime=nvidia --ipc=host -p <host port>:22 --name <container name> -v <host volume 1>:/root/datasets -v <host volume 2>:/root/projects <your image name>`
3. Connect container to network. `docker network connect <your docker network> <your container name>` 
4. Find the ip of your container `docker network inspect <your docker network>`
5. `ssh root@<your container ip` or if your a clever bear you will have modified your `~/.ssh/config` and have some entry in either `/etc/hosts` or some other host file.  `ssh <my super easy to remember name for the container that is saving me so much typing>`
6. `jputer notebook &` exit the container
7. Establish port forwarding from container to remote (the host machine).  `ssh -N -f -L <host port>:localhost:8888 root@<container ip> -p <container ssh port>`  
8. Establist port forwarding from remote host to local. `ssh -N -f -L <local port>:localhost<host port> <user>@<remote>`
9. On the local machine open a browser and navigate to `http://localhost:<local port>`.
10. Add a star to this repo. 

## Configuration samples
### local /etc/hosts
```
999.999.999.999	remote
255.255.255.255	broadcasthost
::1             localhost
```
### local ~/.ssh/config
```
Host remote
	Hostname remote
	IdentityFile ~/.ssh/id_rsa

Host tunnel-remote
	Hostname remote
	IdentityFile ~/.ssh/td_rsa
	LocalForward 10000 localhost:8888
	LocalForward 10001 localhost:6006
	LocalForward 10002 localhost:8000
```
### remote /etc/hosts
Note you should strongly consider using a seperate `hosts` file. <br>
```
172.21.0.2      container     container
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```
### remote ~/.ssh/config
```
Host container
    Hostname container
    IdentityFile ~/.ssh/id_rsa
    User root

Host tunnel-container
    Hostname container
    IdentityFile ~/.ssh/id_rsa
    User root
    LocalForward 8888 localhost:8888
    LocalForward 6006 localhost:6006
    LocalForward 8000 localhost:8000
```

## Contributions Welcomed!
