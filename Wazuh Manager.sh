#!/bin/bash

# Setup Script for Wazuh Manager and Vulnerability Detector

# Step 1: Install Required Packages
apt-get install -y gnupg apt-transport-https

# Step 2: Add Wazuh GPG Key and Repository
echo "Adding Wazuh GPG Key..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

# Step 3: Update Package List and Install Wazuh Manager
apt-get update
apt-get -y install wazuh-manager

# Step 4: Enable and Start Wazuh Manager Service
systemctl daemon-reload
systemctl enable wazuh-manager
systemctl start wazuh-manager

# Step 5: Install Fluent Bit for Log Forwarding
echo "Installing Fluent Bit..."
# Fluent Bit is a log processor and forwarder. It helps collect logs from different sources,
# including Wazuh agents, and sends them to a centralized location for analysis.
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
systemctl enable fluent-bit
systemctl start fluent-bit

# Step 6: Configure Wazuh Authentication
# Set up password authentication for Wazuh
cat <<EOL >> /var/ossec/etc/authd.pass
<CUSTOM_PASSWORD>
EOL
echo "<auth>" >> /var/ossec/etc/ossec.conf
echo "  <use_password>yes</use_password>" >> /var/ossec/etc/ossec.conf
echo "</auth>" >> /var/ossec/etc/ossec.conf

# Step 7: Configure Vulnerability Detector
echo "Configuring Vulnerability Detector..."
cat <<EOL >> /var/ossec/etc/ossec.conf
<vulnerability-detector>
    <enabled>yes</enabled>
    <interval>5m</interval>
    <min_full_scan_interval>6h</min_full_scan_interval>
    <run_on_start>yes</run_on_start>

    <!-- Ubuntu OS vulnerabilities -->
    <provider name="canonical">
      <enabled>yes</enabled>
      <os>trusty</os>
      <os>xenial</os>
      <os>bionic</os>
      <os>focal</os>
      <os>jammy</os>
      <update_interval>1h</update_interval>
    </provider>

    <!-- Debian OS vulnerabilities -->
    <provider name="debian">
      <enabled>yes</enabled>
      <os>stretch</os>
      <os>buster</os>
      <os>bullseye</os>
      <update_interval>1h</update_interval>
    </provider>

    <!-- RedHat OS vulnerabilities -->
    <provider name="redhat">
      <enabled>yes</enabled>
      <os>5</os>
      <os>6</os>
      <os>7</os>
      <os>8</os>
      <os>9</os>
      <update_interval>1h</update_interval>
    </provider>

    <!-- Amazon Linux OS vulnerabilities -->
    <provider name="alas">
      <enabled>yes</enabled>
      <os>amazon-linux</os>
      <os>amazon-linux-2</os>
      <update_interval>1h</update_interval>
    </provider>

    <!-- Arch OS vulnerabilities -->
    <provider name="arch">
      <enabled>yes</enabled>
      <update_interval>1h</update_interval>
    </provider>

    <!-- Windows OS vulnerabilities -->
    <provider name="msu">
      <enabled>yes</enabled>
      <update_interval>1h</update_interval>
    </provider>

    <!-- Aggregate vulnerabilities -->
    <provider name="nvd">
      <enabled>yes</enabled>
      <update_from_year>2010</update_from_year>
      <update_interval>1h</update_interval>
    </provider>
</vulnerability-detector>
EOL

# Step 8: Restart Wazuh Manager
systemctl restart wazuh-manager

# Step 9: Configure Agent Group Files
# Wazuh allows you to manage the configuration of your endpoint agents centrally.
# This means you can set up specific rules and monitor different types of systems
# (like Linux and Windows) from one place. Here’s how to set up groups for each:

# For Linux Agents
echo "Configuring Linux agent group files..."
# Here you would define configurations specific to Linux endpoints, such as what to monitor
# and what rules to apply for those systems. Example:
echo "<group>" >> /var/ossec/etc/ossec.conf
echo "  <name>linux</name>" >> /var/ossec/etc/ossec.conf
echo "  <enabled>yes</enabled>" >> /var/ossec/etc/ossec.conf
echo "</group>" >> /var/ossec/etc/ossec.conf

# For Windows Agents
echo "Configuring Windows agent group files..."
# Similarly, set up configurations for Windows endpoints, specifying relevant monitoring settings.
echo "<group>" >> /var/ossec/etc/ossec.conf
echo "  <name>windows</name>" >> /var/ossec/etc/ossec.conf
echo "  <enabled>yes</enabled>" >> /var/ossec/etc/ossec.conf
echo "</group>" >> /var/ossec/etc/ossec.conf

# Step 10: Install Wazuh Rules from SocFortress
echo "Installing SocFortress Wazuh rules..."
curl -so ~/wazuh_socfortress_rules.sh https://raw.githubusercontent.com/socfortress/Wazuh-Rules/main/wazuh_socfortress_rules.sh
bash ~/wazuh_socfortress_rules.sh

# Final Step: Confirm Setup Completion
echo "Setup completed. Please check the status of Wazuh Manager using:"
echo "sudo systemctl status wazuh-manager"
