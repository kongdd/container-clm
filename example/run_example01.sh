# bash

## initial project
# git clone https://github.com/ESCOMP/cesm
# git clone https://github.com/ESCOMP/ctsm
casename=1850CLM50 # test

rm -rf scratch/1850CLM50 1850CLM50


dir_cime=/model/ctsm/cime
## 1. config_machines
# cp config_machines_intel.xml CLM5/cime/config/machines/config_machines.xml
cp config_machines_gnu.xml ${dir_cime}/config/cesm/machines/config_machines.xml
cp config_compilers.xml    ${dir_cime}/config/cesm/machines/config_compilers.xml

## 2. create_newcase
${dir_cime}/scripts/create_newcase --case $casename --res f19_g16 --compset I2000Clm50Sp --run-unsupported  \
    --compiler gnu --mach kong
    # --compiler intel --mach linux_intel

# cd $casename

# # setup YR_START and YR_END
./xmlchange DATM_CLMNCEP_YR_START=2000,DATM_CLMNCEP_YR_END=2000

./case.setup
./case.build
./case.submit
