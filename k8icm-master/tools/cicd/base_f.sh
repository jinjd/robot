registry_user='admin'
registry_passwd='Harbor12345'

registry='100.2.30.190'
project='incloudos-docker'
date=`date "+%Y%m%d%H%M%S"`
# 临时工作目录
tmp_data=/tmp/tmp_data_$date
# 归档临时工作目录至此
real_data=/tmp/real_data
# icm m 归档文件
icm_m_files=/tmp/icm_m_files

ARCH=amd64