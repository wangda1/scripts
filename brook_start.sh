#!/bin/bash
##  author: wanncy
##  date: 3/12/2019
#==============================================================================
#   TODO： 加入自动连接上 HUST_WIRELESS的脚本，实现不用登录即可联网
#
#
#==============================================================================
#
#   README:
#   1. 需要先修改brooksh（brook启动脚本所在路径）；addr（服务器地址）
#
#==============================================================================
broosh=xxxxxxxxxxx/brook.sh
addr=xxx.xxx.xxx.xxx
brook_PID=
script_PID=
##  打开google-chrome: 172.18.18.60:8080
open_chrome(){
    google-chrome 172.18.18.60:8080 > /dev/null 2>&1 &
}

##  检测brook是否启动，并返回 PID
check_brook(){
    script_PID=$(ps -ef | grep "brook.sh" | grep -v "grep" | grep "bin" | awk '{print $2}')
    brook_PID=$(ps -ef | grep "brook client" | grep "127.0.0.1" | awk '{print $2}')
    if [[ -z "${brook_PID}" ]]; then
        if [[ -n "${script_PID}" ]]; then      ## 如果 brook.sh 残存脚本，但 brook client已关闭
            kill ${script_PID}
        fi
        return 0
    else
        return 1
    fi    
}
##  打开 brook.sh：1.测试服务器状况 2.启动brook
open_brook(){
    echo "开始网络测试：..."
    echo 
    a=$(ping -c 3 ${addr} | grep -Eo "time=[0-9]+")
    if [[ -z "${a}" ]]; then
        echo "网络不可达！"
    else
        echo "测试通过"
        echo "正在启动 brook ..."
        check_brook
        if [[ $? -eq 0 ]]; then
            echo 
            nohup /bin/bash ${brooksh} > /dev/null 2>&1 &
        else
            echo "brook已启动！"
        fi
    fi
    ##  再次检查是否启动成功
    check_brook
    if [[ $? -eq 0 ]]; then
        echo "brook启动失败！"
    else
        echo "brook已启动！"
    fi
}

##  杀死brook：1.先检查是否已启动 2.若已启动杀死进程
kill_brook(){

    check_brook
    if [[ $? -eq 0 ]]; then
        echo "brook没有启动，不用关闭"
    else
        echo ${brook_PID}
        kill ${brook_PID}
    fi
}

echo -e "请输入选项：
1. 启动chrome并打开登陆界面；
2. 连接brook；
3. 杀死brook；
"
read -e -p "请输入数字[1...3]：" option
case $option in
    1) 
    echo "执行chrome"
    check_brook
    echo $?
    echo "brook_PID=${brook_PID}"
    echo "script_PID=${script_PID}"
    open_chrome
    ;;
    2)
    echo "执行brook"
    open_brook
    ;;
    3)
    echo "杀死brook"
    kill_brook
    ;;
    *)
    echo "错误选项，重新输入"
    ;;
esac
