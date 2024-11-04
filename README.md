# Making-SIEM-TOOL
siem-stack-with-open-source-tools

Open Source SIEM Tool
This project is an open-source Security Information and Event Management (SIEM) tool that I built using Wazuh Indexer, Graylog, Fluent Bit, and Wazuh Agent. It’s designed to provide centralized monitoring, real-time analysis, and secure storage for logs and security events across endpoints. This SIEM solution combines these open-source tools to deliver comprehensive log management and intelligent threat detection capabilities for enhanced cybersecurity.

Table of Contents
Features
Architecture Overview
Technologies Used
Installation
1. Setting Up Wazuh Indexer (SIEM Backend)
2. Integrating Graylog for Log Ingestion
3. Deploying Wazuh Manager (Log Analysis)
4. Installing Wazuh Agent for Endpoint Monitoring
5. Enabling Intelligent SIEM Logging
Usage
Configuration
Features -
1. Centralized Log Collection and Analysis - Collects and analyzes logs from multiple endpoints and network sources.
2. Real-Time Endpoint Monitoring - Monitors endpoints with Wazuh Agents for active security insights.
3. Efficient Data Storage - Uses Wazuh Indexer for scalable log indexing and storage.
4. Log Ingestion with Graylog - Handles log aggregation, parsing, and visualization.
5. Scalability and Flexibility - Built with open-source components for both small and large-scale deployments.
6. Intelligent Event Correlation - Supports data-driven threat detection with smart logging and alerting.
Architecture Overview
1. Wazuh Indexer - Acts as the backend storage for all security event data, enabling powerful indexing and search capabilities.
2. Graylog - Manages log ingestion from various sources, processing data before forwarding to Wazuh Indexer.
3. Wazuh Manager - Analyzes logs, correlates events, and triggers alerts based on security insights.
4. Wazuh Agent - Deployed on endpoints to monitor and report security events to Wazuh Manager.
5. Fluent Bit - Lightweight log processor that helps forward and filter logs prior to ingestion by Graylog.
This architecture lets us collect, store, and analyze security events from various sources, enabling proactive threat detection and incident response.

Technologies Used
Wazuh Indexer - For indexing and storing SIEM data.
Graylog - For log aggregation, parsing, and visualization.
Fluent Bit - For lightweight log forwarding and filtering.
Wazuh Manager - For centralized log analysis and event correlation.
Wazuh Agent - For endpoint monitoring and security data collection.

Installation
The installation follows SOCFortress's comprehensive guides. Here’s how I set up each component:
1. Setting Up Wazuh Indexer (SIEM Backend)
Wazuh Indexer is the core backend for storing and indexing logs. To set it up:

Follow Part 1: Wazuh Indexer - SIEM Backend.
Ensure the Wazuh Indexer service is accessible within the network.
Configure storage parameters to handle log data efficiently.
2. Integrating Graylog for Log Ingestion
Graylog ingests and manages logs from various sources. Here’s the setup:

Follow Part 2: Graylog Install & Log Ingestion.
Set up Graylog to collect logs from multiple sources and route them to Wazuh Indexer.
Apply parsing rules and filters for efficient log management.
3. Deploying Wazuh Manager (Log Analysis)
Wazuh Manager processes logs and correlates events from various endpoints:

Refer to Part 3: Wazuh Manager - Log Analysis.
Connect the manager with both Graylog and Fluent Bit.
Configure alert rules to detect and alert on suspicious events.
4. Installing Wazuh Agent for Endpoint Monitoring
Wazuh Agent monitors endpoints and sends data to the Wazuh Manager. Set up each endpoint as follows:

Install Wazuh Agent on each endpoint you wish to monitor using Part 4: Wazuh Agent - Endpoint Monitoring.
Verify that agents are connected to the Wazuh Manager for centralized monitoring and alerting.
5. Enabling Intelligent SIEM Logging
To enable intelligent logging, set up advanced threat detection and event correlation:

Configure additional intelligence-based logging as described in Part 5: Intelligent SIEM Logging.
Add custom rules and visualizations within Graylog and Wazuh.
Enable alerting and notifications based on the intelligence for quick response to threats.
Usage
To start the SIEM tool:

Start Wazuh Indexer to manage backend storage for logs.
Launch Graylog to handle log ingestion from various sources.
Run Wazuh Manager to analyze logs and correlate events across endpoints.
Deploy and run Wazuh Agents on endpoints to gather security data in real-time.
Use Fluent Bit for efficient log processing and forwarding.
You can access the monitoring and alert dashboards via Graylog or Wazuh Manager, which display real-time security event data. Customize these views to suit your security monitoring requirements.

Configuration
For further customization:

Rules and Alerts - Customize alerting thresholds and rules in Wazuh Manager to detect threats specific to your needs.
Log Filters - Use Fluent Bit to set up specific log filters and parsers to streamline log handling.
Dashboards and Reports - Adjust Graylog dashboards for data visualization and set up scheduled reporting.
Threat Intelligence Feeds - Integrate third-party threat feeds for improved detection and correlation.
