#!/usr/bin/env bash
generate_nezha() {
  cat > nezha.sh << EOF
# 哪吒的三个参数
NEZHA_SERVER=${NEZHA_SERVER}
NEZHA_PORT=${NEZHA_PORT}
NEZHA_KEY=${NEZHA_KEY}
TLS=${NEZHA_TLS:+'--tls'}

# 检测是否已运行
check_run() {
  [[ \$(pgrep -lafx nezha-agent) ]] && echo "哪吒客户端正在运行中" && exit
}

# 三个变量不全则不安装哪吒客户端
check_variable() {
  [[ -z "\${NEZHA_SERVER}" || -z "\${NEZHA_PORT}" || -z "\${NEZHA_KEY}" ]] && exit
}

# 下载最新版本 Nezha Agent
download_agent() {
  if [[ $(uname -m | grep 'x86_64') != "" ]]; then
			os_arch="amd64"
		elif [[ $(uname -m | grep 'i386\|i686') != "" ]]; then
			os_arch="386"
		elif [[ $(uname -m | grep 'aarch64\|armv8b\|armv8l') != "" ]]; then
			os_arch="arm64"
		elif [[ $(uname -m | grep 'arm') != "" ]]; then
			os_arch="arm"
		elif [[ $(uname -m | grep 's390x') != "" ]]; then
			os_arch="s390x"
		elif [[ $(uname -m | grep 'riscv64') != "" ]]; then
			os_arch="riscv64"
		fi
		local version=$(curl -m 10 -sL "https://api.github.com/repos/naiba/nezha/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
		if [ ! -n "$version" ]; then
			version=$(curl -m 10 -sL "https://fastly.jsdelivr.net/gh/naiba/nezha/" | grep "option\.value" | awk -F "'" '{print $2}' | sed 's/naiba\/nezha@/v/g')
		fi
		if [ ! -n "$version" ]; then
			version=$(curl -m 10 -sL "https://gcore.jsdelivr.net/gh/naiba/nezha/" | grep "option\.value" | awk -F "'" '{print $2}' | sed 's/naiba\/nezha@/v/g')
		fi
		if [ ! -n "$version" ]; then
			echo -e "获取版本号失败，请检查本机能否链接 https://api.github.com/repos/naiba/nezha/releases/latest"
			return 0
		else
			echo -e "当前最新版本为: ${version}"
		fi
		wget -t 2 -T 10 -O nezha-agent_linux_${os_arch}.zip https://${GITHUB_URL}/naiba/nezha/releases/download/${version}/nezha-agent_linux_${os_arch}.zip >/dev/null 2>&1
		if [[ $? != 0 ]]; then
			echo -e "Release 下载失败，请检查本机能否连接 ${GITHUB_URL}${plain}"
			return 0
		fi
		unzip -qo nezha-agent_linux_${os_arch}.zip && rm -rf nezha-agent_linux_${os_arch}.zip README.md
    chmod +x nezha-agent
  fi
}

# 运行 Nezha 客户端
run() {
  [ -e nezha-agent ] && nohup ./nezha-agent -s \${NEZHA_SERVER}:\${NEZHA_PORT} -p \${NEZHA_KEY} \${TLS} >/dev/null 2>&1 &
}
check_run
check_variable
download_agent
run
EOF
}
generate_nezha
