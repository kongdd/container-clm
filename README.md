## Docker container for Community Land Surface Model CLM5.0

> Dongdong Kong, Sun Yat-sen Universally

*  `CESM` environment is successfully build in this docker image. 

* X11 GUI and sublime text are also supported.  



# Usage

```bash
docker pull kongdd/clm50

git clone kongdd/clm50
cd clm50
./open_linux.sh # linux version
./open_win.ps1  # windows powershell version
```

* Details about this docker repository: 
https://cloud.docker.com/repository/docker/kongdd/clm50/general.

* Document of CLM5.0:
https://escomp.github.io/ctsm-docs/
https://github.com/ESCOMP/ctsm.

----
***Note that:*** make sure the input data directory `ROOT_INPUT` and `ROOT_CLMFORC` exist.



# Tasklist

- [ ] Save configuration and installed package for `sublime text`



# Citation

> **Dongdong Kong**, *2019*, CLM50 docker container, https://github.com/kongdd/container-clm.

