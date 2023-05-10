#!/bin/bash
#
# Run gNB status AFI Prometheus docker image
# www.airfill.io
#
# Set the path to the host afi_conf.yml file location
AFI_CONF="$1"

# Extract the port values from the yml file
GNB_PORT=$(grep -E '^kpi_server_port:' "$AFI_CONF" | awk '{print $2}')
METRIC_PORT=$(grep -E '^kpi_metric_port:' "$AFI_CONF" | awk '{print $2}')

# Run the Docker image - it will run until stopped by $ sudo docker stop ....
sudo docker run --restart=unless-stopped --name afi_kpi_prometheus -d -v "$AFI_CONF:/srv/airfill/config/afi_conf.yml" -p "$GNB_PORT:$GNB_PORT" -p "$METRIC_PORT:$METRIC_PORT" airfill/afi_kpi_prometheus:latest

