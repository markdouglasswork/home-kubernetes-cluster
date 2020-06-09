#!/bin/sh

cp tshock/config-defaults.json /tshock/tshock/config.json
mono --server --gc=sgen -O=all TerrariaServer.exe -config /var/tshock/server-config.txt
