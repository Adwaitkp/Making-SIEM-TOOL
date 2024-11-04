#!/bin/bash

# Setup Script for Wazuh, MongoDB, and Graylog

# Step 1: Update and Install Dependencies
apt-get update
apt-get install -y wget apt-transport-https

# Step 2: Install MongoDB
# MongoDB is a NoSQL database that is commonly used with Graylog for storing log data.
# It provides flexibility, scalability, and high performance for managing large volumes of log data efficiently.
echo "Adding MongoDB GPG Key..."
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
echo "Installing MongoDB..."
sudo apt-get update
sudo apt-get install -y mongodb-org

# Step 3: Enable and Start MongoDB Service
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl restart mongod.service
echo "Active MongoDB Services:"
sudo systemctl --type=service --state=active | grep mongod

# Step 4: Install Graylog
# Graylog uses MongoDB to store its configuration and user data, providing a seamless integration between logging and management.
echo "Downloading and Installing Graylog..."
wget https://packages.graylog2.org/repo/packages/graylog-4.3-repository_latest.deb
sudo dpkg -i graylog-4.3-repository_latest.deb
sudo apt-get update && sudo apt-get install -y graylog-server graylog-integrations-plugins

# Step 5: Setup Graylog Certificates
echo "Setting up Graylog certificates..."
mkdir -p /etc/graylog/server/certs
cp -a /usr/lib/jvm/java-11-openjdk-amd64/lib/security/cacerts /etc/graylog/server/certs/cacerts
keytool -importcert -keystore /etc/graylog/server/certs/cacerts -storepass changeit -alias root_ca -file /etc/graylog/server/certs/rootCA.crt

# Step 6: Configure Graylog Server Options
echo "Configuring Graylog Server..."
GRAYLOG_OPTS="GRAYLOG_SERVER_JAVA_OPTS=\"$GRAYLOG_SERVER_JAVA_OPTS -Dlog4j2.formatMsgNoLookups=true -Djavax.net.ssl.trustStore=/etc/graylog/server/certs/cacerts -Djavax.net.ssl.trustStorePassword=changeit\""
echo $GRAYLOG_OPTS | sudo tee -a /etc/default/graylog-server

# Step 7: Generate Password for Graylog
PASSWORD=$(pwgen -N 1 -s 96)
echo -n "Enter Password: "
read -s INPUT_PASSWORD
HASHED_PASSWORD=$(echo -n "$INPUT_PASSWORD" | sha256sum | cut -d" " -f1)

# Step 8: Configure Elasticsearch Hosts
# Please replace "user", "pass", and "wazuh-indexerhostname" with actual values.
cat <<EOL | sudo tee -a /etc/graylog/server/server.conf
elasticsearch_hosts = https://user:pass@wazuh-indexerhostname:9200
EOL

# Step 9: Restart Graylog Service
echo "Starting Graylog Server..."
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service

echo "Setup completed. Please check the status of Graylog server using:"
echo "sudo systemctl status graylog-server"
