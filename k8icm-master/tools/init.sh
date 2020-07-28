# 解压
mkdir -p /var/lib/registry

tar zxvf ../down/registry_master-fc6c11a-20190508151509.tar.gz -C /var/lib/registry

# 安装ansible
yum install ansible -y