#!/usr/bin/env ash
apk update 
apk add wget curl unzip 
read -p "域名: " NEZHA_SERVER &&
read -p "端口: " NEZHA_PORT &&
read -p "密钥: " NEZHA_KEY
wget https://github.com/naiba/nezha/releases/download/v0.14.12/nezha-agent_linux_386.zip
unzip nezha-agent_linux_386.zip
chmod +x nezha-agent
nohup ./nezha-agent -s \${NEZHA_SERVER}:\${NEZHA_PORT} -p \${NEZHA_KEY} \${TLS} >/dev/null 2>&1 &
