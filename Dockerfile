FROM ubuntu:18.10

## CLM5.0
MAINTAINER "Dongdong Kong"

WORKDIR /model
ENV DEBIAN_FRONTEND=noninteractive

RUN rm  /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ cosmic main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ cosmic-updates main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ cosmic-backports main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ cosmic-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo 'Acquire::https { Verify-Peer "false"; Verify-Host "false"; }' >> /etc/apt/apt.conf.d/tuna.conf

# && echo "deb https://cloud.r-project.org/bin/linux/ubuntu cosmic-cran35/" >> /etc/apt/sources.list

RUN apt-get update \
 && apt install -y --no-install-recommends \
    ca-certificates \
    dejagnu \
    # elfutils-devel \
    vim git subversion gfortran cmake cdo nco ncl-ncarg \
    # r-cran-ncdf4 r-cran-raster \
    m4 zlib1g-dev libhdf5-dev libnetcdff-dev libpnetcdf-dev \
    libopenmpi-dev libmpich-dev \
    libxml2-utils libxml-libxml-perl \
    python

RUN git clone -b release-clm5.0 https://github.com/ESCOMP/ctsm
RUN cd ctsm && ./manage_externals/checkout_externals

# fix link
RUN mkdir /opt/netcdf \
 && ln -sf /usr/include /opt/netcdf/include \
 && ln -sf /usr/lib/x86_64-linux-gnu /opt/netcdf/lib \
 && ln -sf /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3 /usr/lib/liblapack.so \
 && ln -sf /usr/lib/x86_64-linux-gnu/blas/libblas.so.3 /usr/lib/libblas.so

# RUN echo "export " >> /etc/bashrc \
#  && echo "export NETCDF=/opt/netcdf" >> /etc/bashrc \
#  && echo "export NETCDF_PATH=/opt/netcdf" >> /etc/bashrc \
#  && echo "export LD_LIBRARY_PATH=/usr/lib:/usr/lib/x86_64-linux-gnu" >> /etc/bashrc

RUN apt-get update \
 && apt install -y --no-install-recommends \
    apt-utils make

ENV NETCDF=/opt/netcdf \
    NETCDF_PATH=/opt/netcdf \
    CIME=/model/ctsm/cime \
    LD_LIBRARY_PATH=/usr/lib:/usr/lib/x86_64-linux-gnu \
    PATH=/model/ctsm/cime/scripts:/opt/bin:$PATH \
    USER=clm

# inst packages
COPY pkgs/* /opt/bin/

## https://stackoverflow.com/questions/27701930/add-user-to-docker-container
# RUN useradd -rm -s /bin/bash -p ubuntu clm
# USER clm
WORKDIR /home/clm/model

# findpkg netcdf mpich lapack blas
# pkginfo libnetcdf-dev libnetcdff-dev libmpich-dev liblapack3 libblas3
