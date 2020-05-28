FROM arm32v7/mono:6.8.0.96

ARG TSHOCK_VERSION=4.4.0
ADD https://www.terraria.org/system/dedicated_servers/archives/000/000/038/original/terraria-server-1404.zip?1590253816 terraria.zip
RUN apt-get update && \
    apt-get install -y jq moreutils unzip --no-install-recommends && \    
    unzip terraria.zip -d /tshock && \
    rm terraria.zip 
# run the bootstrap, which will copy the TShockAPI.dll before starting the server
WORKDIR /tshock
ENTRYPOINT ["mono", "TerrariaServer.exe"]
