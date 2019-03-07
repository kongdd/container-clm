## 1. change your IP address here for X11 (docker GUI)
# set-variable -name DISPLAY -value :0.0
set-variable -name DISPLAY -value 192.168.1.102:0.0

docker run -it --rm `
    -v /tmp/.X11-unix:/tmp/.X11-unix `
    -v D:\GitHub\model\inputdata:/inputdata `
    -v ${PWD}:/home/clm/cesm `
    -e DISPLAY=$DISPLAY `
    -e USERID=$UID `
    kongdd/clm50 bash 
    # -e USER=$USER 

# docker run -it --rm -v d:/Github/model:/home/clm/model kongdd/clm50 bash 
# powershell docker rm @(docker ps -aq)
# powershell docker rmi @(docker images -f "dangling=true" -q)

# docker run -it --rm -v ${PWD}:/home/clm kongdd/clm50 bash 
# D:\Documents\OneDrive - mail2.sysu.edu.cn\model\inst\container-clm
# docker run -it --rm `
#     -v /tmp/.X11-unix:/tmp/.X11-unix `
#     -v D:\GitHub\model\inputdata:/inputdata `
#     -v ${PWD}:/home/clm/cesm `
#     kongdd/clm50 bash 
    # -e DISPLAY=$DISPLAY `
    # -e USER=$USER -e USERID=$UID `
