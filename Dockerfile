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
    sudo libtool \
    # elfutils-devel \
    vim git subversion gfortran cmake cdo nco ncl-ncarg \
    # r-cran-ncdf4 r-cran-raster \
    libxml2-utils libxml-libxml-perl \
    python \
 && apt-get clean
# libopenmpi-dev 

RUN git clone -b release-clm5.0 https://github.com/ESCOMP/ctsm \
 && cd ctsm && ./manage_externals/checkout_externals && cd ..

# RUN echo "export " >> /etc/bashrc \
#  && echo "export NETCDF=/opt/netcdf" >> /etc/bashrc \
#  && echo "export NETCDF_PATH=/opt/netcdf" >> /etc/bashrc \
#  && echo "export LD_LIBRARY_PATH=/usr/lib:/usr/lib/x86_64-linux-gnu" >> /etc/bashrc

RUN apt install -y --no-install-recommends \
    m4 zlib1g-dev libhdf5-dev libnetcdff-dev libpnetcdf-dev \
    libmpich-dev \
    apt-utils make \
    libglobus-ftp-client-dev \
 && apt-get clean

# fix link
RUN mkdir /opt/netcdf \
 && ln -sf /usr/include /opt/netcdf/include \
 && ln -sf /usr/lib/x86_64-linux-gnu /opt/netcdf/lib \
 && ln -sf /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3 /usr/lib/liblapack.so \
 && ln -sf /usr/lib/x86_64-linux-gnu/blas/libblas.so.3 /usr/lib/libblas.so

# 3. pnetcdf
RUN apt-get install wget tree\
 && wget -qO- http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.10.0.tar.gz | tar xz \
 && cd parallel-netcdf-1.10.0 \
 && autoreconf -f -i \
 && FC=mpif90 CC=mpicc CFLAGS=-fPIC ./configure --enable-shared --prefix=/opt/pnetcdf \
 && make install && cd .. && rm -rf parallel-netcdf-1.10.0

ENV NETCDF=/opt/netcdf \
    NETCDF_PATH=/opt/netcdf \
    PNETCDF_PATH=/opt/pnetcdf \
    CIME=/model/ctsm/cime \
    LD_LIBRARY_PATH=/usr/lib:/usr/lib/x86_64-linux-gnu \
    PATH=/model/ctsm/cime/scripts:/opt/bin:$PATH \
    USER=clm

## References:
# https://stackoverflow.com/questions/27701930/add-user-to-docker-container
# https://stackoverflow.com/questions/25845538/how-to-use-sudo-inside-a-docker-container
RUN useradd -rm -s /bin/bash clm \
 && chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo \
 && echo "root:ubuntu" | chpasswd \
 && echo "clm:ubuntu" | chpasswd \
 && usermod -aG sudo clm \
 && chmod -R 777 /model/ctsm/cime/config/cesm/machines/

# inst packages
COPY bin/* /opt/bin/
COPY example/* /home/clm/model/
COPY pkgs/*.gz /model/

## BUILD NETCDF
# https://www.unidata.ucar.edu/software/netcdf/docs/getting_and_building_netcdf.html
ARG H5DIR=/usr
RUN tar xzf hdf5-1.10.4.tar.gz \
 && cd hdf5-1.10.4 \
 && CC=mpicc ./configure --enable-parallel --prefix=${H5DIR} \
 # && make check \
 && make install && cd .. \
 && rm -rf hdf5-1.10.4 hdf5-1.10.4.tar.gz

ARG NCDIR=/opt/netcdf-4.6.2
RUN tar xzf netcdf-c-4.6.2.tar.gz \
 && cd netcdf-c-4.6.2 \
 && CC=mpicc CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --enable-shared --prefix=${NCDIR} \
 && make check && make install && cd .. \
 && rm -rf netcdf-c-4.6.2 netcdf-c-4.6.2.tar.gz
# --enable-parallel-tests

RUN tar xzf netcdf-fortran-4.4.5.tar.gz \
 && cd netcdf-fortran-4.4.5 \
 && CPPFLAGS='-I/usr/lib' \
    LDFLAG='-L/usr/lib -L/usr/lib/x86_64-linux-gnu' CC=mpicc \
    ./configure --enable-parallel-tests --prefix=${NCDIR} \
 && make check && make install && cd .. \
 && rm -rf netcdf-fortran-4.4.5 netcdf-fortran-4.4.5.tar.gz

# --disable-shared
# RUN cd .. && tar xzf hdf5-1.10.4.tar.gz \
#  && cd hdf5-1.10.4 \
#  && CC=mpicc CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --enable-parallel-tests --prefix=${NCDIR} \
#  && make check && make install && cd ..

# findpkg netcdf mpich lapack blas
# pkginfo libnetcdf-dev libnetcdff-dev libpnetcdf-dev libopenmpi-dev libmpich-dev liblapack3 libblas3 > info_pkg.txt
# USER clm
# WORKDIR /home/clm/model
