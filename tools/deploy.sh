#!/bin/bash

#Dir List 部署节点(即部署节点需要做的操作)
# mkdir -p /deploy/code/web-demo
# mkdir -p /deploy/config/web-demo/base
# mkdir -p /deploy/config/web-demo/other
# mkdir /deploy/tmp
# mkdir /deploy/tar

# chown -R www.www /deploy
# chown -R www.www /webroot
# chown -R www.www /opt/webroot/
# chown -R www.www /webroot

# 需要在客户端节点做的操作
# mkdir /opt/webroot
# mkdir /webroot
# chown -R www.www /webroot
# chown -R www.www /opt/webroot/
# chown -R www.www /webroot
# [www@ ~]$ touch /webroot/web-dem


# Node List 服务器节点
PRE_LIST="192.168.3.12"        # 预生产节点
GROUP1_LIST="192.168.3.12 192.168.3.13"
GROUP2_LIST="192.168.3.13"
ROLLBACK_LIST="192.168.3.12 192.168.3.13"

# 日志日期和时间变量
LOG_DATE='date "+%Y-%m-%d"' # 如果执行的话后面执行的时间，此时间是不固定的，这是记录日志使用的时间
LOG_TIME='date "+%H-%M-%S"'

# 代码打包时间变量
CDATE=$(date "+%Y-%m-%d") # 脚本一旦执行就会取一个固定时间赋值给变量，此时间是固定的
CTIME=$(date +"%H-%M-%S")

# shell env 脚本位置等变量
SHELL_NAME="deploy.sh"    # 脚本名称
SHELL_DIR="/home/www/"  # 脚本路径
SHELL_LOG="${SHELL_DIR}/${SHELL_NAME}.log" # 脚本执行日志文件路径

# code env 代码变量
PRO_NAME="web-demo"    # 项目名称的函数
CODE_DIR="/deploy/code/web-demo"    # 从版本管理系统更新的代码目录
CONFIG_DIR="/deploy/config/web-demo"    # 保存不同项目的配置文件，一个目录里面就是一个项目的一个配置文件或多个配置文件
TMP_DIR="/deploy/tmp"            # 临时目录
TAR_DIR="/deploy/tar"            # 打包目录
LOCK_FILE="/tmp/deploy.lock" # 锁文件路径

usage(){ # 使用帮助函数
    echo $"Usage: $0 [ deploy | rollback [ list | version ]"
}

writelog(){ # 写入日志的函数
    LOGINFO=$1 # 将参数作为日志输入
    echo "${CDATE} ${CTIME} : ${SEHLL_NAME} : ${LOGINFO}" >> ${SHELL_LOG}
}

# 锁函数
shell_lock(){
    touch ${LOCK_FILE}
}

# 解锁函数
shell_unlock(){
    rm -f ${LOCK_FILE}
}

# 获取代码的函数
code_get(){
    echo "code_get"
    writelog code_get
    cd $CODE_DIR && echo "git pull" # 进入到代码目录更新代码，此处必须免密码更新，此目录仅用于代码更新不能放其他任何文件
    cp -rf ${CODE_DIR} ${TMP_DIR}/ # 临时保存代码并重命名，包名为时间+版本号，准备复制到web服务器
    API_VER="123"  # 版本号
}

code_build(){ # 代码编译函数
    echo code_build
}

code_config(){ # 配置文件函数
    writelog code_config
    /bin/cp -rf ${CONFIG_DIR}/base/* ${TMP_DIR}/"${PRO_NAME}" # 将配置文件放在本机保存配置文件的临时目录，用于暂时保存代码项目
    PKG_NAME="${PRO_NAME}"_"$API_VER"_"${CDATE}-${CTIME}"    # 定义代码目录名称
    cd ${TMP_DIR} && mv ${PRO_NAME} ${PKG_NAME}    # 重命名代码文件为web-demo_123-20170629-11-19-10格式
    
}

code_tar(){    # 对代码打包函数
    writelog code_tar
    cd ${TMP_DIR} && tar czf ${PKG_NAME}.tar.gz ${PKG_NAME}
    writelog "${PKG_NAME}.tar.gz" 
}

code_scp(){ # 代码压缩包scp到客户端的函数
    writelog  "code_scp"
    for node in $PRE_LIST;do # 循环服务器节点列表
        scp ${TMP_DIR}/${PKG_NAME}.tar.gz $node:/opt/webroot/ # 将压缩后的代码包复制到web服务器的/opt/webroot
    done

    for node in $GROUP1_LIST;do # 循环服务器节点列表
        scp ${TMP_DIR}/${PKG_NAME}.tar.gz $node:/opt/webroot/ # 将压缩后的代码包复制到web服务器的/opt/webroot
    done
}


url_test(){
    URL=$1
    curl -s --head $URL |grep '200 OK'
    if [ $? -ne 0 ];then
        shell_unlock;
        writelog "test error" && exit;
    fi
}

cluster_node_add(){ #将web服务器添加至前端负载
    echo cluster_node_add
}

cluster_node_remove(){ # 将web服务器从集群移除函数(正在部署的时候应该不处理业务)
    writelog "cluster_node_remove"
}

pre_deploy(){
    writelog "pre_deploy"
    for node in ${PRE_LIST};do # 循环预生产服务器节点列表
        cluster_node_remove  ${node} # 部署之前将节点从前端负载删除
        echo  "pre_deploy, cluster_node_remove ${node}"
        ssh ${node} "cd /opt/webroot && tar zxf ${PKG_NAME}.tar.gz" #分别到web服务器执行压缩包解压命令
        ssh ${node} "rm -f /webroot/web-demo && ln -s /opt/webroot/${PKG_NAME} /webroot/web-demo" # 整个自动化的核心，创建软连接
        done
}

pre_test(){ # 预生产主机测试函数
    for node in ${PRE_LIST};do # 循环预生产主机列表
        curl -s --head http://${node}:9999/index.html | grep "200 OK" # 测试web界面访问
            if [ $? -eq 0 ];then  # 如果访问成功
                writelog " ${node} Web Test OK!" # 记录日志
                echo " ${node} Web Test OK!"
                cluster_node_add ${node} # 测试成功之后调用添加函数把服务器添加至节点,
                writelog "pre,${node} add to cluster OK!" # 记录添加服务器到集群的日志
            else # 如果访问失败
                writelog "${node} test no OK" # 记录日志
                echo "${node} test not OK"
                shell_unlock # 调用删除锁文件函数
            break # 结束部署
        fi
    done

}

group1_deploy(){ # 代码解压部署函数
    writelog "group1_code_deploy"
    for node in ${GROUP1_LIST};do # 循环生产服务器节点列表
        cluster_node_remove $node  
        echo "group1, cluster_node_remove $node"
        ssh ${node} "cd /opt/webroot && tar zxf ${PKG_NAME}.tar.gz" # 分别到各web服务器节点执行压缩包解压命令
        ssh ${node} "rm -f /webroot/web-demo && ln -s /opt/webroot/${PKG_NAME} /webroot/web-demo" # 整个自动化的核心，创建软连接
    done
    scp ${CONFIG_DIR}/other/192.168.3.13.server.xml 192.168.3.13:/webroot/web-demo/server.xml  # 将差异项目的配置文件scp到此web服务器并以项目结尾
}    

group1_test(){ # 生产主机测试函数
    for node in ${PRE_LIST};do # 循环生产主机列表
        curl -s --head http://${node}:9999/index.html | grep "200 OK" #测试web界面访问
        if [ $? -eq 0 ];then  #如果访问成功
            writelog " ${node} Web Test OK!" #记录日志
            echo "group1_test,${node} Web Test OK!"
            cluster_node_add
            writelog " ${node} add to cluster OK!" #记录将服务器 添加至集群的日志
        else #如果访问失败
            writelog "${node} test no OK" #记录日志
            echo "${node} test no OK"
            shell_unlock # 调用删除锁文件函数
            break # 结束部署
        fi
    done
}

rollback_fun(){ 
    for node in $ROLLBACK_LIST;do # 循环服务器节点列表
        # 注意一定要加"号，否则无法在远程执行命令
        ssh $node "rm -f /webroot/web-demo && ln -s /opt/webroot/$1 /webroot/web-demo" # 立即回滚到指定的版本，$1即指定的版本参数
        echo "${node} rollback success!"
        done
}

rollback(){ # 代码回滚主函数
    if [ -z $1 ];then
        shell_unlock # 删除锁文件
        echo "Please input rollback version" && exit 3;
    fi
    case $1 in # 把第二个参数做当自己的第一个参数 
        list)
            ls -l /opt/webroot/*.tar.gz
            ;;
        *)
            rollback_fun $1
    esac
            
}

main(){
    if [ -f $LOCK_FILE ] ;then # 先判断锁文件在不在,如果有锁文件直接退出
        echo "Deploy is running" && exit 10
    fi
    DEPLOY_METHOD=$1 # 避免出错误将脚本的第一个参数作为变量
    ROLLBACK_VER=$2
    case $DEPLOY_METHOD in
        deploy) # 如果第一个参数是deploy就执行以下操作
            shell_lock; # 执行部署之前创建锁。如果同时有其他人执行则提示锁文件存在
            code_get; # 获取代码
            code_build; # 如果要编译执行编译函数
            code_config; # cp配置文件
            code_tar;    # 打包
            code_scp;    # scp到服务器
            pre_deploy;  # 预生产环境部署
            pre_test;    # 预生产环境测试
            group1_deploy; # 生产环境部署
            group1_test;   # 生产环境测试
            shell_unlock; # 执行完成后删除锁文件
            ;;
        rollback) # 如果第一个参数是rollback就执行以下操作
            shell_lock; # 回滚之前也是先创建锁文件
            rollback $ROLLBACK_VER;
            shell_unlock; # 执行完成删除锁文件
            ;;
        *)
            usage;
    esac
}

main $1 $2