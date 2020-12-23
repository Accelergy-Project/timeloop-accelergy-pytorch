FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    vim \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin

RUN wget -O ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /usr/local/bin/conda && \
    rm ~/miniconda.sh

ENV PATH=/usr/local/bin/conda/bin:$PATH
RUN conda install -y python=3.8 && \
    conda install pandas numpy scipy matplotlib ipykernel jupyter && \
    pip install plyplus pyyaml && \
    conda clean -ya

RUN conda install pytorch torchvision cpuonly -c pytorch \
 && conda clean -ya

EXPOSE 8888
