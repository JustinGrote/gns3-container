FROM ubuntu:24.04

RUN <<SCRIPT
apt-get update
apt-get install -y gnupg2
mkdir -p /etc/apt/keyrings

# Add GNS3 PPA repository manually (software-properties-common bloats the image hugely)
gpg --keyserver keyserver.ubuntu.com --recv-keys B83AAABFFBD82D21B543C8EA86C22C2EC6A24D7F
gpg --export B83AAABFFBD82D21B543C8EA86C22C2EC6A24D7F | gpg --dearmor -o /etc/apt/keyrings/gns3-ppa.gpg
CODENAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2)
echo "deb [signed-by=/etc/apt/keyrings/gns3-ppa.gpg] http://ppa.launchpad.net/gns3/ppa/ubuntu $CODENAME main" > /etc/apt/sources.list.d/gns3-ppa.list

# Install GNS3
dpkg --add-architecture i386
apt-get update
apt-get install -y gns3-server gns3-iou
apt-get clean && rm -rf /var/lib/apt/lists/*
SCRIPT

ADD ./start.sh /start.sh
ADD ./config.ini /config.ini

EXPOSE 3080

WORKDIR /data

VOLUME ["/data"]

CMD [ "/start.sh" ]
