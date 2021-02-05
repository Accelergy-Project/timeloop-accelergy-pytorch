FROM timeloopaccelergy/accelergy-timeloop-infrastructure:latest

ENV SRC_DIR=/usr/local/src
ENV BIN_DIR=/usr/local/bin

#
# Set version for s6 overlay
#
ARG OVERLAY_VERSION="v2.1.0.2"
ARG OVERLAY_ARCH="amd64"

#
# Add s6 overlay (until it is added to accelergy-timeloop-infrastructure)
#
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}-installer /tmp/

RUN chmod +x /tmp/s6-overlay-${OVERLAY_ARCH}-installer && \
    /tmp/s6-overlay-${OVERLAY_ARCH}-installer / && \
    rm /tmp/s6-overlay-${OVERLAY_ARCH}-installer

RUN echo "**** create container user and make folders ****" && \
    userdel workspace && \
    useradd -u 911 -U -d /home/workspace -s /bin/bash workspace && \
    usermod -G users workspace

#
# Add conda and python tools
#
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    vim \
&& rm -rf /var/lib/apt/lists/*

WORKDIR $BIN_DIR

RUN wget -O ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $BIN_DIR/conda && \
    rm ~/miniconda.sh

ENV PATH=$BIN_DIR/conda/bin:$PATH

RUN conda install -y python=3.8 && \
    conda install pandas numpy scipy matplotlib ipykernel jupyter && \
    pip install plyplus pyyaml && \
    conda clean -ya

RUN conda install pytorch torchvision cpuonly -c pytorch && \
    conda clean -ya

#
# Install pytorch2timeloop converter
#
RUN python3 -m pip install git+https://github.com/Accelergy-Project/pytorch2timeloop-converter

#
# Install fibertree and associated requirements
#
RUN echo "**** install required packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
               libgl1 \
               fonts-freefont-ttf \
               ttf-dejavu-core && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
       /tmp/* \
       /var/lib/apt/lists/*

RUN python3 -m pip install git+https://github.com/Fibertree-Project/fibertree

#
# Set up root
#
COPY /root /

USER $NB_USER
WORKDIR /home/workspace/

#
# Install notebook extension
#
RUN pip install --no-cache  jupyter_nbextensions_configurator && \
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_index

RUN jupyter nbextensions_configurator enable --sys-prefix  && \
    jupyter nbextension install --py  notebook_index --sys-prefix && \
    jupyter nbextension enable --py  notebook_index --sys-prefix


EXPOSE 8888

ENTRYPOINT ["/init"]

