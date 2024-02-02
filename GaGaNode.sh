#!/bin/bash

# 确定操作系统类型并安装依赖
install_dependencies() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    fi

    if [ $OS == "ubuntu" ] || [ $OS == "debian" ]; then
        sudo apt-get update -y && sudo apt-get -y install curl tar ca-certificates
    elif [ $OS == "centos" ] || [ $OS == "fedora" ]; then
        sudo yum update -y && sudo yum install -y curl tar ca-certificates
    else
        echo "不支持的操作系统"
        exit 1
    fi
}

# 下载并安装应用
download_and_install() {
    ARCH=$(uname -m)
    URL="https://assets.coreservice.io/public/package/60/app-market-gaga-pro/1.0.4/app-market-gaga-pro-1_0_4.tar.gz"

    if [ $ARCH == "x86_64" ]; then
        FILENAME="apphub-linux-amd64.tar.gz"
    elif [ $ARCH == "i386" ] || [ $ARCH == "i686" ]; then
        FILENAME="apphub-linux-i386.tar.gz"
    else
        echo "不支持的架构"
        exit 1
    fi

    curl -o $FILENAME $URL && tar -zxf $FILENAME && rm -f $FILENAME
    cd ./apphub-linux-amd64 || exit
    sudo ./apphub service install
}

# 启动服务
start_service() {
    sudo ./apphub service start
}

# 设置令牌
set_token() {
    if [ -z "$1" ]; then
        read -p "请输入你的令牌: " TOKEN
    else
        TOKEN=$1
    fi
    sudo ./apps/gaganode/gaganode config set --token=$TOKEN
    echo "令牌已设置，请重启应用以使更改生效。"
}

# 重启应用
restart_app() {
    ./apphub restart
}

# 显示常用命令
show_common_commands() {
    echo "常用命令:"
    echo "  sudo ./apphub service install    # 安装节点"
    echo "  sudo ./apphub service start      # 启动节点"
    echo "  sudo ./apphub service stop       # 停止节点"
    echo "  sudo ./apphub service remove     # 移除节点"
    echo "  ./apphub restart                 # 重启节点"
    echo "  ./apphub upgrade                 # 升级节点"
    echo "  ./apphub log                     # 查看日志"
    echo "  ./apphub -h                      # 查看帮助"
    echo ""
}

# 主函数控制流程
main() {
    install_dependencies
    download_and_install
    start_service
    set_token $1
    restart_app
    show_common_commands
}

# 执行主函数
main $@
