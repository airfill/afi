#!/bin/bash
#
# Run gNB status AFI Prometheus docker image
# www.airfill.io
#
# Set the path to the host afi_conf.yml file location
AFI_CONF="$1"

# Extract the Prometheus status_metric_port value from the yml file
METRIC_PORT=$(grep -E '^status_metric_port:' "$AFI_CONF" | awk '{print $2}')

# Run the airfill/sts-test Docker image - it will run until stopped by $ sudo docker stop ....
sudo docker run --restart=unless-stopped --name afi_sts_prometheus -d -v "$AFI_CONF:/srv/airfill/config/afi_conf.yml" -p "$METRIC_PORT:$METRIC_PORT" airfill/afi_sts_prometheus:latest
