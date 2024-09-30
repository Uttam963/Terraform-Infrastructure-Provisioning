#!/bin/bash

# Install prerequisites
sudo apt-get install apt-transport-https -y
sudo apt-get update -y

# Download and install Elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.3-amd64.deb
chmod 777 elasticsearch-7.16.3-amd64.deb
sudo apt install ./elasticsearch-7.16.3-amd64.deb -y

# Enable and start Elasticsearch service
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# Configure Elasticsearch
sudo bash -c 'cat <<EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: elasticsearch
node.name: es-data-0
path.data: /datadisks/disk1/elasticsearch/data
path.logs: /var/log/elasticsearch
network.host: [_site_, _local_]
discovery.seed_hosts: ["es-data-0","es-data-1","es-data-2"]
cluster.initial_master_nodes: ["es-data-0","es-data-1","es-data-2"]
xpack.security.enabled: false
node.attr.fault_domain: 1
node.attr.update_domain: 2
cluster.routing.allocation.awareness.attributes: fault_domain,update_domain
bootstrap.memory_lock: true
node.data: true
node.master: true
node.max_local_storage_nodes: 1
path.repo:
- /mnt/esbackup/backup
search.max_open_scroll_context: 99999
EOF'

# Create backup directory and set permissions
sudo mkdir -p /mnt/esbackup/backup
sudo chmod -R 777 /mnt/esbackup

# Configure systemd for Elasticsearch
sudo bash -c 'cat <<EOF > /etc/systemd/system/elasticsearch.service.d/override.conf
[Service]
LimitMEMLOCK=infinity
EOF'

# Restart Elasticsearch service
sudo systemctl daemon-reload
sudo systemctl restart elasticsearch.service

# Check Elasticsearch service status
sudo systemctl status elasticsearch.service