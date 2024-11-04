# Graylog and Wazuh Integration Tutorial

## Overview
In this tutorial, we will walk through the steps to set up Graylog to receive security logs from Wazuh. We will configure Fluent Bit on our Wazuh Manager to forward the `/var/ossec/logs/alerts/alerts.json` file to Graylog. Without this setup, Graylog would not receive our security logs, and no data would be stored within our Wazuh-Indexer.

**Important:** Please follow PART THREE before progressing with this tutorial.

## Step 1: Verifying Graylog Input
After configuring Fluent Bit, let’s verify that Graylog is receiving data from our Wazuh Manager.

1. **Graylog Receiving Data**: 
   Check your Graylog Input to ensure that data is being received.

2. **View Received Messages**: 
   Select "Received Messages" to view the incoming data.

3. **Expand a Message**: 
   Select a message to expand and view all metadata for that specific event.

### Issue with Received Messages
Unfortunately, the messages are not parsed into key-value pairs; all data is written to a single message field. This format makes it challenging to build dashboards, alerts, and effectively analyze our data.

## Step 2: Using Graylog Extractors
To address the parsing issue, we can utilize Graylog Extractors, which allow us to instruct Graylog on how to extract data from the received messages into distinct fields. 

### Benefits of Extractors
Extractors enable us to perform detailed queries on our logs, enhancing our ability to detect, visualize, and respond to security events.

### Introducing the JSON Extractor
Since Wazuh writes logs in a single-line JSON format, the JSON extractor is an ideal solution. It simplifies the extraction of key-value pairs from the incoming messages.

## Step 3: Configuring the JSON Extractor
To configure the JSON extractor in Graylog:

1. **Select a Message**: 
   In the message field, select "Create extractor."

2. **Choose JSON Extractor Type**: 
   Select the JSON extractor option.

3. **Set Configuration Settings**: 
   Follow the configuration prompts as per your requirements.

4. **Test the Configuration**: 
   Click "Try" to see the parsing results.

5. **Name the Extractor**: 
   Provide a name for your extractor and select "Create Extractor."

6. **Verify Parsed Messages**: 
   Return to your ingested messages and confirm they are now parsed correctly.

## Step 4: Creating an Index
An index in Graylog is how the Wazuh-Indexer stores ingested logs. We need to create an index specifically for Wazuh alerts.

1. **Access Indices**: 
   Select "System" and then "Indices."

2. **Create Index Set**: 
   Click on "Create index set."

3. **Configure Index Settings**: 
   Below is an example configuration; customize as needed:

   - **Index Prefix**: Name of the index (e.g., `wazuh-alerts-socfortress`)
   - **Rotation Strategy**: Set to rotate based on size (e.g., 10GB).
   - **Retention Strategy**: Define how long the index remains (e.g., retain 10 indices).

### Index Configuration Highlights
- **Index Prefix**: Identifies where the data is stored.
- **Rotation Strategy**: How often the index rotates (e.g., `wazuh-alerts-socfortress_0` to `wazuh-alerts-socfortress_1` upon reaching size limits).
- **Retention Strategy**: Duration the index is kept before deletion (e.g., maximum total size of 100GB).

## Step 5: Creating the Stream
Graylog streams route messages into categories in real-time, which is essential for organizing logs effectively.

1. **Create Stream**: 
   Select "Streams" and then "Create Stream."

2. **Name Your Stream**: 
   Set a name and link it to your newly created index. Select "Remove matches from 'All messages' stream."

3. **Save the Stream**: 
   Click "Save" to finalize the creation.

4. **Add Static Field**: 
   In your stream, select "Add static field" and add `log_type` with a value of `wazuh`.

5. **Manage Stream Rules**: 
   Select "Stream" and then "Manage Rules."

6. **Add Stream Rule**: 
   Click "Add stream rule" to set up routing based on your static field.

7. **Start the Stream**: 
   Select "I'm done!" to complete the setup and start the stream.

## Step 6: Viewing Ingested Messages
1. **Select the Stream**: 
   Navigate to your stream to view ingested messages.

2. **Inspect Indexed Logs**: 
   Choose a message and verify which index your Wazuh logs are stored in.

## Conclusion
In this tutorial, we learned how to parse received Wazuh alerts, create unique indices, and route logs to the correct index. The ability to analyze and route logs is crucial for any SOC team or MSP. 

You can apply this same approach to ingest logs from firewalls, cloud services (AWS/GCP/Azure), and other third-party sources. Now you have the power—go take control of your logs! Happy Defending! 😄
