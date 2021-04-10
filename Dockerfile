FROM ubuntu:20.04

## CLM5.0
MAINTAINER "Dongdong Kong"

WORKDIR /model
ENV DEBIAN_FRONTEND=noninteractive

ENV VERSION_CODENAME=bionic
# cosmic

RUN rm /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo "deb [trusted=yes] https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list \
 && echo 'Acquire::https { Verify-Peer "false"; Verify-Host "false"; }' >> /etc/apt/apt.conf.d/tuna.conf

# && echo "deb https://cloud.r-project.org/bin/linux/ubuntu cosmic-cran35/" >> /etc/apt/sources.list

RUN apt-get update \
 && apt install -y --no-install-recommends --assume-yes \
    ca-certificates \
    dejagnu \
    sudo libtool \
    # elfutils-devel \
    vim git subversion gfortran cmake cdo nco ncl-ncarg \
    # r-cran-ncdf4 r-cran-raster \
    libxml2-utils libxml-libxml-perl \
    python \
    make m4 \
    libcurl4-openssl-dev liblapack-dev libblas-dev mpich libmpich-dev \
 && apt-get clean

# libopenmpi-dev
ADD pkgs/*.gz /usr/local/src/

ARG ZDIR=/usr/local/zlib
RUN cd /usr/local/src/zlib-1.2.11 \
 && CC=mpicc ./configure --prefix=${ZDIR} \
 && make \
 # && make check \
 && make install \
 && rm -rf /usr/local/src/zlib-1.2.11

ENV CC=mpicc \
    CXX=mpicxx \
    FC=mpif90 \
    F77=mpif90

ARG PNDIR=/usr/local/pnetcdf
RUN cd /usr/local/src/pnetcdf-1.11.0 \
 && FC=mpif90 MPICC=mpicc CFLAGS="-fPIC -g -O2" \
    ./configure --prefix=${PNDIR} --enable-shared --enable-profiling\
 && make \
 # && make tests \
 # && make check \
 # && make ptests \
 && make install \
 && rm -rf /usr/local/src/pnetcdf-1.11.0

# Parallel OpenMPI-HDF5-NetCDF stack
# https://gist.github.com/milancurcic/3a6c1a97a99d291f88cc61dae6621bdf
ARG H5DIR=/usr/local/hdf5
RUN cd /usr/local/src/hdf5-1.10.4 \
 && CC=mpicc FC=mpif90 CFLAGS="-fPIC -w" ./configure --prefix=${H5DIR} \
 --with-zlib=${ZDIR} --enable-parallel --enable-hl \
 && make \
 # && make check \
 && make install \
 && rm -rf /usr/local/src/hdf5-1.10.4
#--enable-shared --enable-fortran

ARG NCDIR=/usr/local/netcdf4
RUN cd /usr/local/src/netcdf-c-4.6.2 \
 && CC=mpicc CPPFLAGS="-I${PNDIR}/include -I${H5DIR}/include -I${ZDIR}/include" \
    LDFLAGS="-L${PNDIR}/lib -L${H5DIR}/lib -L${ZDIR}/lib" \
    ./configure --prefix=${NCDIR} --enable-parallel-tests \
 && make \
 # && make check \
 && make install \
 && rm -rf /usr/local/src/netcdf-c-4.6.2

ARG NFDIR=/usr/local/netcdff4
RUN cd /usr/local/src/netcdf-fortran-4.4.5 \
 && CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib \
    ./configure --prefix=${NFDIR} \
 && make \
 # && make check \
 && make install \
 && rm -rf /usr/local/src/netcdf-fortran-4.4.5

RUN echo ${NCDIR}/lib > /etc/ld.so.conf.d/netcdf.conf \
 && echo ${NFDIR}/lib >> /etc/ld.so.conf.d/netcdf.conf \
 && echo ${ZDIR}/lib >> /etc/ld.so.conf.d/netcdf.conf \
 && echo ${H5DIR}/lib >> /etc/ld.so.conf.d/netcdf.conf \
 && echo ${PNDIR}/lib >> /etc/ld.so.conf.d/netcdf.conf \
 && ldconfig

# Install wget and x11
RUN apt install -y --assume-yes gnupg wget curl \
 && apt install -y --no-install-recommends --assume-yes \
    x11-apps tree \
 && apt-get clean

# Sublime text
# ARG SUBLIME_BUILD="${SUBLIME_BUILD:-3200}"
# RUN curl -O https://download.sublimetext.com/sublime-text_build-"${SUBLIME_BUILD}"_amd64.deb \
#  && dpkg -i -R sublime-text_build-"${SUBLIME_BUILD}"_amd64.deb || echo "\n Will force install of missing ST3 dependencies...\n"
RUN wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - \
 && echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list \
 && apt update \
 && apt install sublime-text -y

## 3.1 add user
ENV USER=clm
RUN useradd -m -G adm,sudo -s /bin/bash $USER \
 && echo "root:root" | chpasswd \
 && echo "clm:clm" | chpasswd \
 && apt-get remove wget -y

## 3.2 clone CLM5.0 repository
RUN git clone -b release-clm5.0 https://github.com/ESCOMP/ctsm \
 && cd ctsm && ./manage_externals/checkout_externals \
 && chown -R clm:clm /model/ctsm \
 && cd ..

## 3.3 Configuration
VOLUME [ "/inputdata"]
ENV PATH="/model/ctsm/cime/scripts:${NCDIR}/bin:${PATH}" \
    LANG=C.UTF-8

COPY config/*.xml /home/${USER}/.cime/
COPY config /home/${USER}/cesm/config
COPY run_CLM50_example01.sh /home/${USER}/cesm/

WORKDIR /home/${USER}/cesm

RUN chown -R clm:clm /home /home/${USER} /home/${USER}/.cime /inputdata
 # && chmod 755 -R /inputdata /home/${USER}/.cime /home/${USER} \
 # && echo 'export DISPLAY=:0.0' >> /etc/profile, chown

# ARG GIT_SSL_NO_VERIFY=true
# RUN cd /home/${USER} \
#  && git clone -b release-clm5.0 https://github.com/ESCOMP/ctsm.git clm5 \
#  && cd clm5 \
#  && ./manage_externals/checkout_externals
USER ${USER}
CMD bash
