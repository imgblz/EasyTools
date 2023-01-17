#!/bin/bash

#################################################
# EasyTools      # by阿杰の杰
# 此脚本仅为自己方便维护服务器而写，不保证适用于所有人
# 各种C+V，不喜勿喷
# 其实就是一个合集，可以方便的安装一些常用的软件
# 注释什么的是为了我这个废物好找，不要在意~
#################################################

##标记版本
version="0.0.1"

##标记更新时间
update_time="2023-01-16"

##标记当前版本更新日志
version_log="v0.0.1: 第一版"

##定义颜色 红，黄，蓝，绿，紫，青
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
GREEN="\033[32m"
PURPLE="\033[35m"
CYAN="\033[36m"

##检测是否为root用户
if [ $(id -u) != "0" ]; then
    echo -e "${RED}Error: 您需要root权限执行该脚本${WHITE}"
    exit 1
fi

##检测更新版本
##获取云端版本号，无法访问则输出本地版本号，定义为upversion
upversion=$(curl -s -m 10 https://raw.githubusercontents.com/imgblz/EasyTools/main/version.yaml | grep "version=" | awk -F '"' '{print $2}')
##检查upversion是否与本地版本号相同，不同则更新，upversion为空则不更新
if [ "$upversion" != "$version" ]; then
    echo -e "${RED}检测到新版本，正在更新${WHITE}"
    wget -q -N --no-check-certificate https://raw.githubusercontents.com/imgblz/EasyTools/main/EasyTools.sh && chmod +x EasyTools.sh
    echo -e "${GREEN}更新完成，正在重新执行${WHITE}"
    ./EasyTools.sh
    exit 0
fi

##top
top(){
    echo "##########################################################"
    echo -e "            ${RED}EasyTools${PLAIN}"
    echo -e " ${GREEN}我的博客${PLAIN}: https://blog.imgblz.cn"
    echo -e " ${GREEN}项目地址${PLAIN}: https://github.com/imgblz/EasyTools"
    echo -e " ${GREEN}Raw 加速${PLAIN}: https://ghraw.imgblz.cn"
    echo "##########################################################"
}


##抄点MisakaToolbox遗产，自己写的不好用
##这里没啥问题就不改了，反正我啥也不会

##遗产区开始##
##系统检查
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora")
PACKAGE_UPDATE=("apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "yum -y install")
PACKAGE_REMOVE=("apt -y remove" "apt -y remove" "yum -y remove" "yum -y remove" "yum -y remove")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove")

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')") 

for i in "${CMD[@]}"; do
    SYS="$i" && [[ -n $SYS ]] && break
done

for ((int = 0; int < ${#REGEX[@]}; int++)); do
    if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
        SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
    fi
done

[[ $EUID -ne 0 ]] && red "请在root用户下运行脚本" && exit 1
[[ -z $SYSTEM ]] && red "不兼容该系统" && exit 1

##CHECK区开始## *需要在menu添加*
check_status(){
    yellow "等下！你这vps就是逊了..."
    if [[ -z $(type -P curl) ]]; then
        yellow "安装curl..."
        if [[ ! $SYSTEM == "CentOS" ]]; then
            ${PACKAGE_UPDATE[int]}
        fi
        ${PACKAGE_INSTALL[int]} curl
    fi
    if [[ -z $(type -P sudo) ]]; then
        yellow "安装sudo..."
        if [[ ! $SYSTEM == "CentOS" ]]; then
            ${PACKAGE_UPDATE[int]}
        fi
        ${PACKAGE_INSTALL[int]} sudo
    fi

    IPv4Status=$(curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
    IPv6Status=$(curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)

    if [[ $IPv4Status =~ "on"|"plus" ]] || [[ $IPv6Status =~ "on"|"plus" ]]; then
        wg-quick down wgcf >/dev/null 2>&1
        v66=`curl -s6m8 https://ip.gs -k`
        v44=`curl -s4m8 https://ip.gs -k`
        wg-quick up wgcf >/dev/null 2>&1
    else
        v66=`curl -s6m8 https://ip.gs -k`
        v44=`curl -s4m8 https://ip.gs -k`
    fi

    if [[ $IPv4Status == "off" ]]; then
        w4="${RED}未使用WARP${PLAIN}"
    fi
    if [[ $IPv6Status == "off" ]]; then
        w6="${RED}未使用WARP${PLAIN}"
    fi
    if [[ $IPv4Status == "on" ]]; then
        w4="${YELLOW}WARP free账户${PLAIN}"
    fi
    if [[ $IPv6Status == "on" ]]; then
        w6="${YELLOW}WARP free账户${PLAIN}"
    fi
    if [[ $IPv4Status == "plus" ]]; then
        w4="${GREEN}WARP+ 或 Teams账户${PLAIN}"
    fi
    if [[ $IPv6Status == "plus" ]]; then
        w6="${GREEN}WARP+ 或 Teams账户${PLAIN}"
    fi

    if [[ -n $v66 ]] && [[ -z $v44 ]]; then
        VPSIP=0
    elif [[ -z $v66 ]] && [[ -n $v44 ]]; then
        VPSIP=1
    elif [[ -n $v66 ]] && [[ -n $v44 ]]; then
        VPSIP=2
    fi

    v4=$(curl -s4m8 https://ip.gs -k)
    v6=$(curl -s6m8 https://ip.gs -k)
    c4=$(curl -s4m8 https://ip.gs/country -k)
    c6=$(curl -s6m8 https://ip.gs/country -k)
    s5p=$(warp-cli --accept-tos settings 2>/dev/null | grep 'WarpProxy on port' | awk -F "port " '{print $2}')
    w5p=$(grep BindAddress /etc/wireguard/proxy.conf 2>/dev/null | sed "s/BindAddress = 127.0.0.1://g")
    if [[ -n $s5p ]]; then
        s5s=$(curl -sx socks5h://localhost:$s5p https://www.cloudflare.com/cdn-cgi/trace -k --connect-timeout 8 | grep warp | cut -d= -f2)
        s5i=$(curl -sx socks5h://localhost:$s5p https://ip.gs -k --connect-timeout 8)
        s5c=$(curl -sx socks5h://localhost:$s5p https://ip.gs/country -k --connect-timeout 8)
    fi
    if [[ -n $w5p ]]; then
        w5s=$(curl -sx socks5h://localhost:$w5p https://www.cloudflare.com/cdn-cgi/trace -k --connect-timeout 8 | grep warp | cut -d= -f2)
        w5i=$(curl -sx socks5h://localhost:$w5p https://ip.gs -k --connect-timeout 8)
        w5c=$(curl -sx socks5h://localhost:$w5p https://ip.gs/country -k --connect-timeout 8)
    fi

    if [[ -z $s5s ]] || [[ $s5s == "off" ]]; then
        s5="${RED}未启动${PLAIN}"
    fi
    if [[ -z $w5s ]] || [[ $w5s == "off" ]]; then
        w5="${RED}未启动${PLAIN}"
    fi
    if [[ $s5s == "on" ]]; then
        s5="${YELLOW}WARP 免费账户${PLAIN}"
    fi
    if [[ $w5s == "on" ]]; then
        w5="${YELLOW}WARP 免费账户${PLAIN}"
    fi
    if [[ $s5s == "plus" ]]; then
        s5="${GREEN}WARP+ / Teams${PLAIN}"
    fi
    if [[ $w5s == "plus" ]]; then
        w5="${GREEN}WARP+ / Teams${PLAIN}"
    fi
}

##遗产区结束##

##这里是功能区##

##功能区开始##



##功能区结束##

##菜单main开始##
main(){
    ##检查状态##
    check_status
    ##清理屏幕##
    clear
    ##显示logo##
    top
    ##显示版本
    echo -e "  ${GREEN}当前版本：${PLAIN}${YELLOW}v${VERSION}${PLAIN}${PLAIN}${YELLOW}${version_time}${PLAIN}"
    echo -e "${YELLOW}更新日志${PLAIN}：$version_log"
    ##显示系统信息##
    echo -e "  ${GREEN}系统信息：${PLAIN}${YELLOW}${OS} ${OS_VERSION} ${ARCH}${PLAIN}"
    ##linux内核版本
    echo -e "  ${GREEN}内核版本：${PLAIN}${YELLOW}${KERNEL_VERSION}${PLAIN}"
    ##虚拟化架构##
    echo -e "  ${GREEN}虚拟化架构：${PLAIN}${YELLOW}${VIRT}${PLAIN}"
    ##显示IP信息##
    if [[ -n $v4 ]]; then
        echo -e "IPv4 地址：$v4"  
        echo -e "地区：$c4  WARP状态：$w4"
    fi
    if [[ -n $v6 ]]; then
        echo -e "IPv6 地址：$v6 " 
        echo -e "地区：$c6  WARP状态：$w6"
    fi
    if [[ -n $w5p ]]; then
        echo -e "WireProxy代理端口: 127.0.0.1:$w5p  WireProxy状态: $w5"
        if [[ -n $w5i ]]; then
            echo -e "WireProxy IP: $w5i  地区: $w5c"
        fi
    fi
    echo ""
}






##菜单main结束##
main
