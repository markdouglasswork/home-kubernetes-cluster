### Mark's Raspberry Pi Kubernetes Adventure (thus far)

#### Goals
- Learn something about Kubernetes
- Learn something about Raspberry Pi
- Monitor the hardware underlying my cluster
- Offload some of the work for running a game from my laptop to...something

#### Stretch Goals
- Monitor my home computers
- Monitor the k8s cluster itself
- Allow persistent user accounts in the game running on the cluster
- Secure the cluster itself
- Distribute all credentials securely between apps
- Publish the persistent terraria server for use by some folks online

#### High Level Strategy
- Link a few Raspberry Pi devices together in a Kubernetes cluster
- Install Prometheus and Grafana on the cluster
- Install Terraria Server on the cluster
- PROFIT!(?)

#### Walkthrough
For the sake of transparency, I will mention that I used other people's published walkthroughs for much of this work.
Where it makes sense, I will start with a link to another walkthrough, and only write up corrections or distinctions here.

##### Creating a cluster!
To get my cluster up and running, I started with [this guide](https://medium.com/nycdev/k8s-on-pi-9cc14843d43), but had to make a few modifications.
Please read on to see what I had to change.
1. The method used to disable swap (step 2 of Common Setup) does not seem to persist through reboot. I had to run `sudo systemctl disable dphys-swapfile.service`.
1. IP forwarding has to be enabled on each of the PIs to allow containers to accept outside traffic.
  * Open `/etc/sysctl.conf` with your favorite editor.
  * You should be able to find a line that looks like this: `#net.ipv4.ip_forward=1`
  * Take out the leading '#' to uncomment the line, save the file, and reboot the PI.
Other than those modifications, I was able to use the above guide as it was to get a functional cluster.

##### Getting Prometheus up and running
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

##### Exposing Prometheus
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

##### Adding the prometheus node exporter to the Pis

##### Adding temperature readings to the outgoing Pi data

##### Configuring up Prometheus to scrape the Pis
Ok, now I want prometheus to scra

##### Setting up persistence for Prometheus

##### Getting Grafana up and running

##### Actually monitoring the devices with Grafana

##### Getting Terraria up and running

##### Configuring Terraria to generate and run a world on startup

##### Persisting the Terraria worlds through pod relocations and cluster restarts

##### Allowing persistent user accounts in the Terraria server via MySQL

##### Monitoring my home hardware with Prometheus
