FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04
LABEL maintainer="Josh Lee joshlee@ischool.berkeley.edu"

##########################
# Update the environment #
##########################
RUN apt-get -y update && \
        apt-get -y install \
        build-essential \
        bzip2 \
        ca-certificates \
        cmake \
        gfortran \
        git \
        libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
        libxvidcore-dev libx264-dev \
        libatlas-base-dev \
        libgtk-3-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libv4l-dev \
        libz-dev \
        python3-dev \
        pkg-config \
        unzip \
        wget 

#################################
# Set cuda environment vriables #
#################################

ENV LD_LIBRARY_PATH=/usr/local/cuda-9.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV PATH=/usr/local/cuda-9.2/bin${PATH:+:${PATH}}


# A more efficient approach would be to download the specific python 3.6.8 installer.

##################################
# Install Anaconda in /opt/conda #
##################################

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
  wget --quiet https://repo.continuum.io/archive/Anaconda3-2018.12-Linux-x86_64.sh -O /anaconda.sh && \
  /bin/bash /anaconda.sh -b -p /opt/conda && \
  rm -rf /anaconda.sh

##################################################################
# Downgrade to a python version that tensorflow-gpu 1.12 can use #
##################################################################

ENV PATH /opt/conda/bin:$PATH
RUN conda install python=3.6.8

############################################
# Install dependencies for python packages #
############################################

RUN rm -rf /opt/conda/pkgs/wrapt-1* && \
  rm -rf /opt/conda/lib/python3.6/site-packages/wrapt

RUN conda install \
        tensorflow-gpu \
        keras && \
  pip install \
        future \
        protobuf \
        typing \
        hypothesis \
        onnx \
        netron \
        fastprogress \
        nvidia-ml-py3 \
        cymem murmurhash \
        dill \
        ujson \
        wrapt \
        msgpack-numpy \
        preshed \
        plac \
        thinc \
        regex \
        spacy \
#        torchvision \
        dataclasses

RUN pip install \
	bcolz \
	graphviz \
	sklearn_pandas \
	isoweek \
	pandas_summary \
#	torchtext==0.2.3 \
	feather-format \
	jupyter_contrib_nbextensions \
	plotnine \
	docrepr \
	awscli \
	kaggle-cli \
	pdpbox \
	seaborn \
	dataclasses \
	nvidia-ml-py3 \
	future \
	protobuf \
	typing \
	hypothesis

##################
# Install Caffe2 #
##################

#RUN git clone https://github.com/pytorch/pytorch.git /pytorch
#WORKDIR /pytorch
#RUN git submodule update --init --recursive && \
#    python setup.py install

RUN conda install pytorch torchvision -c pytorch
RUN pip install torchtext==0.2.3

####################
# Install OpenCV 4 #
####################

WORKDIR /
RUN wget --quiet https://github.com/opencv/opencv/archive/4.0.0.zip -O opencv.zip && \
    wget --quiet https://github.com/opencv/opencv_contrib/archive/4.0.0.zip -O opencv_contrib.zip && \
    unzip opencv.zip && \
    unzip opencv_contrib.zip && \
    mv opencv-4.0.0 opencv && \
    mv opencv_contrib-4.0.0 opencv_contrib
WORKDIR /opencv
RUN mkdir build
WORKDIR /opencv/build

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D BUILD_opencv_java=OFF \
    -D WITH_CUDA=ON \
    -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 \
    -D WITH_CUBLAS=1 \
    -D WITH_OPENCL=OFF \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON \
    -D PYTHON_EXECUTABLE=/opt/conda/bin/python3.6 \
    -D PYTHON_INCLUDE=/opt/conda/include/python3.6m\
    -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.6m.a \
    -D PYTHON_PACKAGES_PATH=/opt/conda/lib/python3.6/site-packages/ \
    -D PYTHON_NUMPY_INCLUDE_DIR=/opt/conda/lib/python3.6/site-packages/numpy/core/include/numpy ..

# set to 10 for 8700k or <=30 for 1950x or <= 60 for 2990wx
RUN make -j30 && \
    make install && \
    ldconfig

##################################
# Rename and link cv2 executable #
##################################

WORKDIR /usr/local/python/cv2/python-3.6/
RUN mv cv2.cpython-36m-x86_64-linux-gnu.so cv2.so
WORKDIR /opt/conda/lib/python3.6/site-packages/
RUN ln -s /usr/local/python/cv2/python-3.6/cv2.so cv2.so

##################
# Install fastai #
##################

#RUN conda install -c pytorch -c fastai fastai
#RUN conda uninstall --force jpeg libtiff -y && \
#conda install -c conda-forge libjpeg-turbo && \
#CC="cc -mavx2" pip install --no-cache-dir -U --force-reinstall --no-binary :all: --compile pillow-simd

#####################
# Install detectron #
#####################

ENV Caffe2_DIR /pytorch/build
ENV PYTHONPATH /pytorch/build:${PYTHONPATH}
ENV LD_LIBRARY_PATH /pytorch/build/lib:${LD_LIBRARY_PATH}

RUN git clone https://github.com/facebookresearch/detectron /detectron
RUN pip install -r /detectron/requirements.txt
WORKDIR /detectron
RUN make

#########################################
# Install forgotton fastai dependencies #
########################################
RUN pip install pillow==5.3.0

#################
# WTF no vim??? #
#################

RUN apt install -y vim

################
# Install coco #
################
 
WORKDIR /
RUN git clone https://github.com/cocodataset/cocoapi.git /coco
WORKDIR /coco/PythonAPI/
RUN make
RUN python setup.py install

##################
# Install fastai #
##################

#RUN pip install fastai --no-dependencies
RUN conda install -c fastai fastai=1.0.42 

###############
# Final Setup #
###############

RUN mkdir /root/.jupyter && \
    echo "c.NotebookApp.ip = '0.0.0.0'" \
    "\nc.NotebookApp.open_browser = False" \
    "\nc.NotebookApp.token = ''" \
    "\nc.NotebookApp.allow_root = True" \
    > /root/.jupyter/jupyter_notebook_config.py

#################################
# Install sshd and configure it #
################################
# This is based on the docker example

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:8675309' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

################
# Expose ports #
################

# Expose port for sshd
EXPOSE 22
# Expose port for jupyter server
#EXPOSE 8888
# Expose port for TensorBoard
#EXPOSE 6006
# Expose port for python webserver
#EXPOSE 8000 8080
# Expose port for flask
#EXPOSE 10000

RUN mkdir /root/datasets && mkdir /root/projects
VOLUME ["/root/datasets", "/root/projects"]
WORKDIR /root
RUN ln -s / /root/top-level && \
    ln -s /detectron /root/detectron
#CMD ["/bin/bash"]
CMD ["/usr/sbin/sshd", "-D"]

