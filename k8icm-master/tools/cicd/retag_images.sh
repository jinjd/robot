#!/bin/bash
#
# 生成离线镜像, 并重新生成tag
# liupeng/liupeng04@inspur.com
# 20190130
#
source ./base_f.sh

# 传递参数
tag=$1-$date
echo $tag >/tmp/tag-$tag
branch_name=$2
latest_tag=$branch_name-latest
# latest_tag=master-latest

# 创建相关目录
mkdir -p $tmp_data
mkdir -p $real_data

# for test
# branch='master'
# tag=$branch-$date

# login registry
docker login -u$registry_user -p$registry_passwd $registry

# 启动前清理
docker stop registry
docker rm registry
# 启动仓库
registryv2_image=$registry/dockerio/registry-amd64
docker run -d  -p 5000:5000 --name registry $registryv2_image
# 追加默认镜像
# curl http://100.2.29.151/k8s_bin/registry_0.5.1.7.tar.gz \
#     | tar -xz -C $tmp_data/


# docker cp $tmp_data/docker/ registry:/var/lib/registry/

for k in `cat image_list_$ARCH|grep -v ^# | grep -v ^$`;do
    docker pull $registry/$k

    docker tag $registry/$k localhost:5000/$k

    # push 本地仓库
    docker push localhost:5000/$k
done

# retag icm images
for i in `cat service_list|grep -v ^# | grep -v ^$`;do
    docker pull $registry/$project/$i:$latest_tag

    docker tag $registry/$project/$i:$latest_tag $registry/$project/$i:$tag
    docker tag $registry/$project/$i:$latest_tag localhost:5000/$project/$i:$tag

    docker push $registry/$project/$i:$tag
    # push 本地仓库
    docker push localhost:5000/$project/$i:$tag
done

# 归档data
pwd
docker cp registry:/var/lib/registry/docker $tmp_data/
tar zcvf ../../down/registry_$tag.tar.gz -C $tmp_data docker
ls ../../down/registry_$tag.tar.gz

# 下载bin
curl http://100.2.29.151/k8s_bin/k8s.1-11-6_2.tar.gz \
    | tar -xz -C ../../

ls ../../

# registryv2_image
docker tag $registryv2_image registry-amd64:latest
docker save registry-amd64:latest -o ../../down/registry_$ARCH.tar

# 清理
docker stop registry
docker rm registry
