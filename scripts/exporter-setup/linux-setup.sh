#!/usr/bin/env bash

sudo apt update
sudo apt install -y prometheus-node-exporter golang-go

if ! sudo apt install -y datacenter-gpu-manager ; then
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
  sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
  sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
  sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
fi

sudo apt update
sudo apt-get install -y datacenter-gpu-manager

mkdir -p ~/workspace
if [ -d "~/workspace/gpu-monitoring-tools" ] ; then
  git clone https://github.com/NVIDIA/gpu-monitoring-tools.git ~/gpu-monitoring-tools
fi

pushd ~/workspace/gpu-monitoring-tools
  git pull --rebase
  make binary
  sudo make install
popd

sudo install -m 557 ./exporter-config/linux/dcgm-exporter.service /etc/systemd/system/dcgm-exporter.service
sudo install -m 557 ./exporter-config/linux/dcgm-counters.csv /etc/dcgm-exporter/default-counters.csv
