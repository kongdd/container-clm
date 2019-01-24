## Docker container for Community Land Surface Model (CLM5.0)

> Dongdong Kong, Sun Yat-sen Universally

# Usage

```bash
docker pull kongdd/clm50
docker run -it --rm -v d:/Github/model:/home/clm/model kongdd/clm50 bash 
```

* Details about this docker repository: 
https://cloud.docker.com/repository/docker/kongdd/clm50/general.

* Document of CLM5.0:
https://escomp.github.io/ctsm-docs/
https://github.com/ESCOMP/ctsm.

----
# How to install docker  
https://mirror.tuna.tsinghua.edu.cn/help/docker-ce/

*<u>Note that `linux` package mirror has been changed to `tsinghua`.*</u>

### Ubuntu
```bash
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce
```

### Fedora/CentOS/RHEL
```bash
sudo yum remove docker docker-common docker-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo
sudo sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo

sudo yum makecache fast
sudo yum install docker-ce
```
