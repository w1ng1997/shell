#!/bin/bash

# 备份旧配置
BACKUP_DIR="/etc/yum.repos.d/backup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 移动现有的 .repo 文件到备份目录
if mv /etc/yum.repos.d/*.repo "$BACKUP_DIR/" 2>/dev/null; then
    echo "旧的 Yum 源配置文件已备份到 $BACKUP_DIR"
else
    echo "警告：没有找到需要备份的 .repo 文件或备份失败"
fi

# 生成新配置
cat > /etc/yum.repos.d/base.repo << 'EOF'
[base]
name=HCE $releasever base
baseurl=http://repo.huaweicloud.com/hce/$releasever/os/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://repo.huaweicloud.com/hce/$releasever/os/RPM-GPG-KEY-HCE-2

[updates]
name=HCE $releasever updates
baseurl=http://repo.huaweicloud.com/hce/$releasever/updates/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://repo.huaweicloud.com/hce/$releasever/updates/RPM-GPG-KEY-HCE-2

[debuginfo]
name=HCE $releasever debuginfo
baseurl=http://repo.huaweicloud.com/hce/$releasever/debuginfo/$basearch/
enabled=0
gpgcheck=1
gpgkey=http://repo.huaweicloud.com/hce/$releasever/debuginfo/RPM-GPG-KEY-HCE-2
EOF

echo "新的 Yum 源配置文件已生成"

# 清理缓存并更新
if yum clean all && yum makecache; then
    echo "Yum 缓存已成功清理并更新"
else
    echo "警告：清理和更新 Yum 缓存时发生错误"
fi

echo "Yum 源更新完成！"
