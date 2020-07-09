# Mark's Raspberry Pi Kubernetes Adventure (thus far)

## Goals
- Learn something about Kubernetes
- Learn something about Raspberry Pi
- Monitor the hardware underlying my cluster
- Offload some of the work for running a game from my laptop to...something

## Stretch Goals
- Monitor my home computers
- Monitor the k8s cluster itself
- Allow persistent user accounts in the game running on the cluster
- Secure the cluster itself
- Distribute all credentials securely between apps
- Publish the persistent terraria server for use by some folks online

## High Level Strategy
- Link a few Raspberry Pi devices together in a Kubernetes cluster
- Install Prometheus and Grafana on the cluster
- Install Terraria Server on the cluster
- PROFIT!(?)

## Walkthrough
For the sake of transparency, I will mention that I used other people's published walkthroughs for much of this work.
Where it makes sense, I will start with a link to another walkthrough, and only write up corrections or distinctions here.

### Creating a cluster!
To get my cluster up and running, I started with [this guide](https://medium.com/nycdev/k8s-on-pi-9cc14843d43), but had to make a few modifications.
Please read on to see what I had to change.
1. The method used to disable swap (step 2 of Common Setup) does not seem to persist through reboot. I had to run `sudo systemctl disable dphys-swapfile.service`.
1. IP forwarding has to be enabled on each of the PIs to allow containers to accept outside traffic.
  * Open `/etc/sysctl.conf` with your favorite editor.
  * You should be able to find a line that looks like this: `#net.ipv4.ip_forward=1`
  * Take out the leading '#' to uncomment the line, save the file, and reboot the PI.
Other than those modifications, I was able to use the above guide as it was to get a functional cluster.

### Getting Prometheus up and running
After setting the cluster up, it was time to run some software.
I thought it would be fun to have cluster the monitor its own hardware.
To get a prometheus pod up and running was not too, I had to create a k8s manifest:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-deployment
  labels:
    app: prometheus
    purpose: monitor-household-stuff
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
      purpose: monitor-household-stuff
  template:
    metadata:
      labels:
        app: prometheus
        purpose: monitor-household-stuff
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus
        ports:
        - containerPort: 9090
```
But this is a true dial tone Prometheus.
I have to ssh into its container to talk to it,
and it has only the single default scrape config that comes with the docker image.

#### Exposing Prometheus
I want to be able to communicate with the Prometheus instance from a browser...
Turns out I have to add another k8s entity to the manifest above (it could also go in its own file, but meh...)
```yaml
---
kind: Service
apiVersion: v1
metadata:
  name: prometheus-service
spec:
  selector:
    app: prometheus
    purpose: monitor-household-stuff
  ports:
  - name: promui
    protocol: TCP
    port: 9090
    targetPort: 9090
```
This exposes the port to other pods running within kubernetes, and they will be able to discover it with the hostname `prometheus-service`

#### Adding the prometheus node exporter to the Pis
I didn't do much discovery here, a Google search led me to [this](https://linuxhit.com/prometheus-node-exporter-on-raspberry-pi-how-to-install/) guide.
I used the directions to create a systemd controlled process to ensure that the exporter would always restart itself.
I followed it without incident until it asked me to run this command to verify my work: `curl http://localhost:9100/metrics` 
I did find that output was missing a key piece of information I wanted, the Pi temperature reading.

##### Adding temperature readings to the outgoing Pi data
!! Warning: This section is presently reconstructed from memory, and I haven't verified the exact commands and filenames yet, but the high level idea is correct
I definitely wasn't ok skipping this, so I decided to figure it out.
I discovered that there is a simple bash command that can return the temperature: `/opt/vc/bin/vcgencmd measure_temp`.
I also noticed that the instructions above to set up a systemd daemon for the node exporter included a text file collection directory:
```bash
ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector
```
Given this, I added a cron job to each pi to export the temperature to a file each minute.
I first created a simple bash script, it looked like this:
```bash
#!/bin/bash
/opt/vc/bin/vcgencmd measure_temp > /var/lib/node_exporter/textfile_collector/temp
```
You can open the cron table with `crontab -e`.
In the text file that's opened, add a task that looks something like this: `* * * * * /users/pi/scripts/export-temperature.sh`

#### Configuring up Prometheus to scrape the Pis
Ok, now I want prometheus to scrape my Raspberry  Pi prometheus endpoints, so I can record the data.

#### Setting up persistence for Prometheus
If I want my metrics history to persist through restarts, I'll need to

##### Configuring NFS Shares on another server
You'll need a computer running Linux or MacOS.
I used an old, unneeded laptop running Ubuntu Server.
You could use an old desktop or another Pi.
If using another Pi, I would recommend using a USB port to hook it up to something other than the SD card.

### Getting Grafana up and running

### Actually monitoring the devices with Grafana
It was easy to manually create a dashboard to look at what I wanted each time, but who wants to do that?
I decided to set up a set of charts that would be loaded automatically by grafana each time i

### Getting Terraria up and running

### Configuring Terraria to generate and run a world on startup

### Persisting the Terraria worlds through pod relocations and cluster restarts

### Allowing persistent user accounts in the Terraria server via MySQL

### Monitoring my home hardware with Prometheus
