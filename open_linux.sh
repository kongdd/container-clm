# /bin/bash
# Change to your IP here
DISPLAY=192.168.1.102:0.0

docker run -it --rm \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /inputdata:/inputdata \
    -v ${PWD}:/home/clm/cesm \
    -e DISPLAY=$DISPLAY \
    -e USERID=$UID \
    kongdd/clm50 bash 
