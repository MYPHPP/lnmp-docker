#!/bin/bash
# by skywalkerwei 2018.12.03
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
is64bit=`getconf LONG_BIT`
#setup_path=/

if [ "$is64bit" != '64' ];then
	echo "====================================="
	echo "抱歉, 6.0不支持32位系统, 请使用64位系统!";
	exit 0;
fi

command_exists() {
	command -v "$@" > /dev/null 2>&1
}


Install_Check(){
	while [ "$yes" != 'y' ] && [ "$yes" != 'n' ]
	do
		echo -e "----------------------------------------------------"
		echo -e "docker install tool"
		echo -e "----------------------------------------------------"
		read -p "输入yes强制安装/Enter y to force installation (y/n): " yes;
	done 
	if [ "$yes" == 'n' ];then
		exit;
	fi

	if [ -z ${setup_path} ]; then
    	setup_path=/
      	read -p "默认安装路径 /,请输入你想安装的路径 : " setup_path
      	if [ "${setup_path}" = '' ]; then
        	setup_path=/
    	fi
    fi

	D_Info=('简化版' '基础版本' '完全版')
    if [ -z ${DSelect} ]; then
        DSelect="2"
        Echo_Yellow "You have 11 options for your DataBase install."
        echo "1: Install ${D_Info[0]}"
        echo "2: Install ${D_Info[1]} (Default)"
        echo "3: Install ${D_Info[2]}"
        read -p "Enter your choice (1, 2, 3): " DSelect
    fi

}


do_install(){

	Install_Check
	
	yum -y update

	yum install ntp -y
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	echo 'Asia/Shanghai' >/etc/timezone

	if command_exists docker; then
		echo "docker 已安装"
	else
		curl -fsSL get.docker.com -o get-docker.sh
		sudo sh get-docker.sh --mirror Aliyun
		systemctl enable docker
		systemctl start docker
	fi

	if command_exists pip; then
		echo "pip 已安装"
	else
		yum -y install epel-release
		yum -y install python-pip
	fi

	if command_exists docker-compose; then
		echo "compose 已安装"
	else
		pip install docker-compose --ignore-installed requests	
	fi

	if command_exists git; then
		echo "git 已安装"
	else
		yum -y install git
	fi
	sudo gpasswd -a ${USER} docker
	mkdir -p $setup_path
	cd $setup_path
	git clone https://github.com/skywalkerwei/dnmp.git
  	cd dnmp
	cp env.sample .env 


	if [ "${DSelect}" = "1" ]; then
        mv -f  docker-compose-sample.yml  docker-compose.yml
    elif [ "${DSelect}" = "2" ]; then
        mv -f  docker-compose-base.yml  docker-compose.yml
    elif [ "${DSelect}" = "3" ]; then
        mv -f docker-compose-full.yml  docker-compose.yml 
    fi

	docker-compose up
	mkdir -p ../wwwroot/Jenkins/workspace
	chmod -R 777 ../wwwroot/

}

do_install
