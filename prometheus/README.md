![image](https://airfill.io/afgit15.png)
## Quick start guide for AFI Prometheus containers
---
**Note that this guide is for testing purposes and is not meant for production deployment.**

### Install Docker
If you do not have Docker Engine installed, please follow official Docker [installation guide](https://docs.docker.com/engine/install/ubuntu/).


### AFI Configuration 
All AFI containers can be configured using [afi_conf.yml](https://github.com/airfill/afi/blob/main/config/afi_conf.yml) and editing corresponding section.

#### Run gNB Status container
Edit the afi_conf.yml and enter the IP addresses of gNBs that you want to monitor. Optionally, you can modify status update interval and Prometheus scrape port also.

Download [run_afi_sts_prometheus.sh](https://github.com/airfill/afi/blob/main/prometheus/run_afi_sts_prometheus.sh) (if it is not executable, make it by *chmod +x run_afi_sts_prometheus.sh*) and start the status container by:
```
$ ./run_afi_sts_prometheus.sh <path-of-afi_conf.yml>
```
Check the container log:
```
$ sudo docker logs afi_sts_prometheus
```
Once the container is running, you will be able to see status metrics in Prometheus GUI:

<div style="display:flex">
  <img src="https://airfill.io/git-img/sts_cell1.png" style="width:50%">
  <img src="https://airfill.io/git-img/sts_sync.png" style="width:50%">
</div>

Container will run (including after reboot) until it is stopped by:
```
$ sudo docker stop afi_sts_prometheus
```
After the container is stopped, to restart or update the container:
```
$ sudo docker rm  afi_sts_prometheus
$ ./run_afi_sts_prometheus.sh <path-of-afi_conf.yml>
```

#### Run gNB KPI container
Edit the afi_conf.yml if you need to modify gNB KPI server port (this needs to match gNB configuration) or Prometheus scrape port.

Download [run_afi_kpi_prometheus.sh](https://github.com/airfill/afi/blob/main/prometheus/run_afi_kpi_prometheus.sh) (if it is not executable, make it by *chmod +x run_afi_kpi_prometheus.sh*) and start the status container by:
```
$ ./run_afi_kpi_prometheus.sh <path-of-afi_conf.yml>
```
Check the container log:
```
$ sudo docker logs afi_kpi_prometheus
```
Once the container is running, you will be able to see status metrics in Prometheus GUI:

<div style="display:flex">
  <img src="https://airfill.io/git-img/kpi_rsrp2.png" style="width:50%">
  <img src="https://airfill.io/git-img/kpi_prb1.png" style="width:50%">
</div>

To stop or update the container, you can use the following steps as before: first, stop the container by running *sudo docker stop afi_kpi_prometheus*. Then, remove the container by running *sudo docker rm afi_kpi_prometheus*. Finally, run the *run_afi_sts_prometheus.sh* script again to pull new image or with the updated configuration file to restart the container.

### Install Prometheus

There are multiple ways to install Prometheus as documented in [Installing Prometheus](https://prometheus.io/docs/prometheus/latest/installation/). In this quick guide, we will use pre-compiled binaries and install on a Ubuntu 22.04 server.

Download [linux-amd64 LTS version](https://github.com/prometheus/prometheus/releases/download/v2.37.8/prometheus-2.37.8.linux-amd64.tar.gz) from [prometheus.io](https://prometheus.io/download/)

Extract downloaded .tar.gz file to /opt/prometheus/ (or to a directory of your choice)  

Go to /opt/prometheus/ directory and do a test run:
```
$ sudo ./prometheus
```
#### Add AFI to Prometheus Config
Edit prometheus.yml and add AFI to scrape_config section:

```
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

  - job_name: 'afi-gnb-status'
    static_configs:
      - targets: ["localhost:9080"]

  - job_name: 'afi-gnb-kpi'
    static_configs:
      - targets: ["localhost:9081"]
      
```

#### Create and Configure Prometheus Service  
Create prometheus.service in the /etc/systemd/system/ directory and add the following contents:

```
[Unit]
Description=Prometheus Server

[Service]
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml
Restart=on-abort
``` 
Reload the systemd daemon to read the new service file:
```
$ sudo systemctl daemon-reload
```
Start the Prometheus service: 
```
$ sudo systemctl start prometheus
```
Check the status of the Prometheus service: 
```
$ sudo systemctl status prometheus
```
If the service is running, enable it to start automatically at boot:
```
$ sudo systemctl enable prometheus
```

You can access the Prometheus GUI by opening a web browser and navigating to http://<prometheus_server_ip>:9090, where <prometheus_server_ip> is the IP address of your Prometheus server.

Check your scrape targets status:

<img src="https://airfill.io/git-img/pmt_targets.png" alt="Prometheus Targets" width="400" height="125" />


Resources for Prometheus:
* [https://prometheus.io/docs/tutorials/getting_started/](https://prometheus.io/docs/tutorials/getting_started/)
* [https://promlabs.com/promql-cheat-sheet/](https://promlabs.com/promql-cheat-sheet/)
* [https://www.prometheusbook.com/MonitoringWithPrometheus_sample.pdf](https://www.prometheusbook.com/MonitoringWithPrometheus_sample.pdf)
* [https://prometheus.io/docs/visualization/grafana/](https://prometheus.io/docs/visualization/grafana/)
