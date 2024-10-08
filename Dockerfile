ARG ARCH="amd64"
FROM timeloopaccelergy/accelergy-timeloop-infrastructure:latest-${ARCH}

LABEL maintainer="timeloop-accelergy@mit.edu"

# Arguments
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels - org.local-schema
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="timeloopaccelergy/timeloop-accelergy-pytorch"
LABEL org.label-schema.description="Infrastructure for Timeloop/Accelergy and Pytorch"
LABEL org.label-schema.url="http://accelergy.mit.edu/"
LABEL org.label-schema.vcs-url="https://github.com/Accelergy-Project/timeloop-accelergy-pytorch"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="Emer"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker run -it --rm -v ~/workspace:/home/workspace timeloopaccelergy/timeloop-accelergy-pytorch"

ENV SRC_DIR=/usr/local/src
ENV LIB_DIR=/usr/local/lib
ENV BIN_DIR=/usr/local/bin

RUN echo "**** create container user and make folders ****" && \
    userdel workspace && \
    useradd -u 911 -U -d /home/workspace -s /bin/bash workspace && \
    usermod -G users workspace

#
# Python tools
#
RUN pip3 install pandas seaborn numpy scipy matplotlib ipykernel jupyter && \
    pip3 install plyplus pyyaml && \
    pip3 install tqdm matplotlib svgutils

RUN pip3 install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 \
    --extra-index-url https://download.pytorch.org/whl/cpu

RUN python3 -m pip install torchprofile

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
               fonts-dejavu && \
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
#RUN pip3 install --no-cache  jupyter_nbextensions_configurator && \
#    pip3 install git+https://github.com/NII-cloud-operation/Jupyter-LC_index

#RUN jupyter nbextensions_configurator enable --sys-prefix  && \
#    jupyter nbextension install --py  notebook_index --sys-prefix && \
#    jupyter nbextension enable --py  notebook_index --sys-prefix

#
# Install Yaml Widgets
#
RUN python3 -m pip install git+https://github.com/jsemer/yamlwidgets

EXPOSE 8888

ENTRYPOINT ["/init"]
