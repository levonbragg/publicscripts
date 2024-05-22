#!/bin/bash
#
# Install Zabbix Proxy and edit the config for PSK
#

IDENTITY=""
read -p "Enter Hostname (Must match on Zabbix Server): " IDENTITY

PSK_IDENTITY=""
read -p "Enter PSK Identity: " PSK_IDENTITY

SERVER=""
read -p "Enter the Zabbix Server IP/Name: " SERVER


wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian12_all.deb
dpkg -i zabbix-release_6.4-1+debian12_all.deb
apt update
apt install --reinstall -o Dpkg::Options::="--force-confask,confnew,confmiss" zabbix-proxy-sqlite3=1:6.4.14-1+debian12 -y

systemctl enable zabbix-proxy
systemctl stop zabbix-proxy

# Setup PSK Encryption
openssl rand -hex 64 > /etc/zabbix/zabbix_proxy.psk
chown zabbix:zabbix /etc/zabbix/zabbix_proxy.psk
chmod 640 /etc/zabbix/zabbix_proxy.psk

#Backup File
cp /etc/zabbix/zabbix_proxy.conf /etc/zabbix/zabbix_proxy.bak


# Add our config     # sed "s/<>/<>/" /etc/zabbix/zabbix_proxy.conf
sed -i "s/# ProxyMode=0/ProxyMode=0/" /etc/zabbix/zabbix_proxy.conf
sed -i "s/Server=127.0.0.1/Server=$SERVER/" /etc/zabbix/zabbix_proxy.conf
sed -i "s/Hostname=Zabbix proxy/Hostname=$IDENTITY/" /etc/zabbix/zabbix_proxy.conf

# Setup PSK Encryption
sed -i "s/# TLSConnect=unencrypted/TLSConnect=psk/" /etc/zabbix/zabbix_proxy.conf
sed -i "s/# TLSAccept=unencrypted/TLSAccept=psk/" /etc/zabbix/zabbix_proxy.conf
sed -i "s/# TLSPSKFile=/TLSPSKFile=/home/zabbix/zabbix_proxy.psk/" /etc/zabbix/zabbix_proxy.conf
sed -i "s/# TLSPSKIdentity=/TLSPSKIdentity=$PSK_IDENTITY/" /etc/zabbix/zabbix_proxy.conf
sed -i "s/DBName=zabbix_proxy/DBName=/tmp/zabbix_proxy/" /etc/zabbix/zabbix_proxy.conf

systemctl start zabbix-proxy

echo $SERVER
echo $IDENTITY
echo $PSK_IDENTITY
cat /etc/zabbix/zabbix_proxy.psk
