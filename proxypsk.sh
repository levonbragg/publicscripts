#!/bin/bash

PSK_IDENTITY=""
read -p "Enter PSK Identity: " PSK_IDENTITY

openssl rand -hex 64 > /etc/zabbix/zabbix_proxy.psk
cat /etc/zabbix/zabbix_proxy.psk
chown zabbix:zabbix /etc/zabbix/zabbix_proxy.psk
chmod 640 /etc/zabbix/zabbix_proxy.psk

echo "### Setup PSK encryption with the Zabbix Server ###" >> /etc/zabbix/zabbix_proxy.conf
echo "TLSConnect=psk" >> /etc/zabbix/zabbix_proxy.conf
echo "TLSAccept=psk" >> /etc/zabbix/zabbix_proxy.conf
echo "TLSPSKFile=/home/zabbix/secret.psk" >> /etc/zabbix/zabbix_proxy.conf
echo "TLSPSKIdentity="$PSK_IDENTITY" >> /etc/zabbix/zabbix_proxy.conf
