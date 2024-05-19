#!/bin/bash

# 设置仓库URL和本地目录
REPO_URL="https://github.com/felixonmars/dnsmasq-china-list.git"
LOCAL_DIR="dnsmasq-china-list"

CHINA_CONF="accelerated-domains.china.smartdns.conf"
APPLE_CONF="apple.china.smartdns.conf"

# 检查本地目录是否存在
if [ -d "$LOCAL_DIR" ]; then
    # 如果目录存在，进入该目录并尝试更新
    echo "目录已经存在，尝试更新仓库..."
    cd "$LOCAL_DIR"
    git pull
else
    # 如果目录不存在，克隆仓库到本地
    echo "目录不存在，开始克隆仓库..."
    git clone "$REPO_URL"
    cd "$LOCAL_DIR"
fi

# 输出完成信息
echo "更新仓库完成"

# 清理仓库未提交文件
git clean -fd

# Start to generate smartdns config
make SERVER=CN smartdns

# 检查本地目录是否存在
if [ -f "$CHINA_CONF" ]; then
    # 如果目录存在，进入该目录并尝试更新
    echo "China域名文件已生成..."
else
    # 如果目录不存在，克隆仓库到本地
    echo "China域名文件未生成，请检查脚本代码..."
    exit 1
fi

# 检查本地目录是否存在
if [ -f "$APPLE_CONF" ]; then
    # 如果目录存在，进入该目录并尝试更新
    echo "Apple域名文件已生成..."
else
    # 如果目录不存在，克隆仓库到本地
    echo "Apple域名文件未生成，请检查脚本代码..."
    exit 1
fi

echo "停止SmartDNS"
/etc/init.d/smartdns stop

echo "复制China域名文件到Domain-set"
cp -f "$CHINA_CONF" /etc/smartdns/domain-set/

echo "复制Apple域名文件到Domain-set"
cp -f "$APPLE_CONF" /etc/smartdns/domain-set/

echo "启动SmartDNS"
/etc/init.d/smartdns start

echo "Operation finished"