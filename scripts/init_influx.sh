#!/bin/bash


curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/$${DISTRIB_ID,,} $${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list


apt-get update
apt-get install influxdb
service influxdb start


wget https://dl.influxdata.com/chronograf/releases/chronograf_1.7.14_amd64.deb
sudo dpkg -i chronograf_1.7.14_amd64.deb

chronograf

echo 'create DB influxdb'

curl -XPOST 'http://localhost:8086/query' --data-urlencode 'q=CREATE DATABASE "lambda"'

apt-get -qq -y install wget

apt-get install -qq -y libfontconfig1
apt-get install -f

wget https://dl.grafana.com/oss/release/grafana_6.4.4_amd64.deb
sudo dpkg -i grafana_6.4.4_amd64.deb

systemctl daemon-reload

systemctl enable grafana-server.service
systemctl start grafana-server.service