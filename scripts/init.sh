#!/bin/bash

useradd -rs /bin/false influxdb

apt-get -qq -y install wget

wget https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.20_linux_amd64.tar.gz
tar xvzf influxdb_2.0.0-alpha.20_linux_amd64.tar.gz
sudo cp influxdb_2.0.0-alpha.20_linux_amd64/{influx,influxd} /usr/local/bin/

influxd 

sleep 35


