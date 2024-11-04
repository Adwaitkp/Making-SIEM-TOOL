
#!/bin/bash

# Wazuh Backend Setup Script
# This script automates the setup for Wazuh Indexer, Server, and Dashboard.

# Step 1: Download Wazuh Certificate Tool and Configuration File
curl -sO https://packages.wazuh.com/4.3/wazuh-certs-tool.sh
curl -sO https://packages.wazuh.com/4.3/config.yml

# Update config.yml with node information
cat <<EOL > config.yml
nodes:
  indexer:
    - name: node-1
      ip: <indexer-node-ip>
    # Add additional nodes here if needed
  server:
    - name: wazuh-1
      ip: <wazuh-manager-ip>
  dashboard:
    - name: dashboard
      ip: <dashboard-node-ip>
EOL

# Step 2: Generate Certificates
bash ./wazuh-certs-tool.sh -A
tar -cvf ./wazuh-certificates.tar -C ./wazuh-certificates/ .

# Step 3: Install Required Packages
apt-get install -y debconf adduser procps gnupg apt-transport-https

# Step 4: Add Wazuh Repository and Install Wazuh Indexer
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
apt-get update
apt-get -y install wazuh-indexer

# Step 5: Configure Wazuh Indexer
cat <<EOL >> /etc/wazuh-indexer/indexer.yml
cluster.initial_master_nodes:
  - "node-1"
  - "node-2"
  - "node-3"

discovery.seed_hosts:
  - "10.0.0.1"
  - "10.0.0.2"
  - "10.0.0.3"

plugins.security.nodes_dn:
  - "CN=node-1,OU=Wazuh,O=Wazuh,L=California,C=US"
  - "CN=node-2,OU=Wazuh,O=Wazuh,L=California,C=US"
  - "CN=node-3,OU=Wazuh,O=Wazuh,L=California,C=US"
EOL

export NODE_NAME=<indexer-node-name>
echo "bootstrap.memory_lock: true" >> /etc/wazuh-indexer/indexer.yml

# Step 6: Configure Systemd Service for Wazuh Indexer
sed -i '/\[Service\]/a LimitMEMLOCK=infinity' /usr/lib/systemd/system/wazuh-indexer.service
echo "-Xms4g" >> /usr/lib/systemd/system/wazuh-indexer.service
echo "-Xmx4g" >> /usr/lib/systemd/system/wazuh-indexer.service

# Reload and start Wazuh Indexer
systemctl daemon-reload
systemctl enable wazuh-indexer
systemctl start wazuh-indexer

# Initialize security for Wazuh Indexer
/usr/share/wazuh-indexer/bin/indexer-security-init.sh

# Verify Wazuh Indexer setup
curl -k -u admin:admin https://<WAZUH_INDEXER_IP>:9200/_cat/nodes?v

# Step 7: Install Additional Packages for Dashboard
apt-get install -y debhelper tar curl libcap2-bin

# Step 8: Install Wazuh Dashboard
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
apt-get update
apt-get -y install wazuh-dashboard

# Configure Wazuh Dashboard
cat <<EOL >> /etc/wazuh-dashboard/dashboard.yml
server.host: 0.0.0.0
server.port: 443
opensearch.hosts: https://localhost:9200
opensearch.ssl.verificationMode: certificate
EOL

export NODE_NAME=<dashboard-node-name>

# Enable and start Wazuh Dashboard
systemctl daemon-reload
systemctl enable wazuh-dashboard
systemctl start wazuh-dashboard

# Configure OpenSearch passwords for Wazuh Dashboard
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh --change-all
echo <kibanaserver-password> | /usr/share/wazuh-dashboard/bin/opensearch-dashboards-keystore --allow-root add -f --stdin opensearch.password

# Restart Wazuh Dashboard to apply changes
systemctl restart wazuh-dashboard

echo "Wazuh backend setup completed."
