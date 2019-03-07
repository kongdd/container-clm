# /bin/bash

## initial project
# git clone https://github.com/ESCOMP/cesm
# git clone https://github.com/ESCOMP/ctsm
casename=~/cesm/1850Clm50Bgc # test
# rm -rf $casename # scratch/1850CLM50 1850CLM50
# rm -rf $casename

dir_cime=/model/ctsm/cime
# dir_cime=~/clm5/cime

# ${dir_cime}/config/cesm/machines/
# ${dir_cime}/config/cesm/machines
## 1. config_machines
# cp config_machines_intel.xml CLM5/cime/config/machines/config_machines.xml
cp config/config_machines.xml  ~/.cime/config_machines.xml
cp config/config_compilers.xml ~/.cime/config_compilers.xml

## 2. create_newcase
${dir_cime}/scripts/create_newcase --case $casename --res f19_g16 --compset I1850Clm50Bgc --run-unsupported  \
    --compiler gnu --mach kong

# ${dir_cime}/scripts/create_newcase --case year2019 --res f19_g16 --compset I1850Clm50Bgc --run-unsupported \
    # --compiler gnu --mach kong
    # --compiler intel --mach linux_intel
cd $casename # I1850Clm50Bgc, I2000Clm50Sp

# # setup YR_START and YR_END
# ./xmlchange DATM_CLMNCEP_YR_START=2000,DATM_CLMNCEP_YR_END=2000
# ./xmlchange NTASKS=2

## CLM5 configure
ROOT_INPUT=/inputdata/cesminput # ${HOME}/cesm
ROOT_CLMFORC=${ROOT_INPUT}/atm/datm7 # lmwg # 

./xmlquery DATM_CLMNCEP_YR_START,DATM_CLMNCEP_YR_END
./xmlchange DATM_CLMNCEP_YR_START=2010,DATM_CLMNCEP_YR_END=2010
./xmlquery NTASKS
./xmlchange NTASKS=2 #[核心数]
./xmlquery DIN_LOC_ROOT,DIN_LOC_ROOT_CLMFORC
./xmlchange DIN_LOC_ROOT=${ROOT_INPUT},DIN_LOC_ROOT_CLMFORC=${ROOT_CLMFORC}

./xmlquery STOP_N
./xmlquery STOP_OPTION

./xmlchange STOP_N=14,STOP_OPTION=ndays

## build and submit task
./case.setup
./case.build
./case.submit
