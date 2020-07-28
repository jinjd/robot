# 1 文档介绍

## 1.1 文档目的
本文档描述了icm-m版本的环境搭建部署，指导实施人员完成icm-m环境的部署实施工作。

***先决条件***

文档中首先会在 baremetal 环境中构建一套包含 addons 的 Kubernetes 集群;

同时保证有足够的资源运行中间件环境。

## 1.2 读者对象
适应于软件开发、维护及实施人员，并且需要具有一定的 kubernetes/linux/ansible 知识。

## 1.3  术语
本节介绍文档中出现的相关术语。

|术语|解释|
|---|----|
|kubernetes|开源容器编排引擎|
|helm||
|ansible||
|||


# 2 获取离线安装包
二进制及离线镜像文件：http://100.2.29.151/k8s_bin/

ansible-playbook:http://100.2.50.206/ICM/k8icm

注意：服务器需要单独配置yum仓库，以供安装keepalived、haproxy、ipvs等软件

# 3 系统要求

## 3.1 硬件要求
    服务器内存 >= 8G
    服务CPU >= 4C
    服务器 docker volume 硬盘 >= 50G

    需提供外部存储

## 3.2 系统软件要求

>
> CentOS 7.4 base image

> ansible >= 2.6

> docker = 17.03.2-ce, 18.06.1-ce
>




# 4 k8s部署

## 4.1 集群规划
高可用集群所需节点配置如下(最小部署单位)：

- 部署节点------x1 : 运行这份 ansible 脚本的节点
- etcd节点------x3 : 注意etcd集群必须是1,3,5,7...奇数个节点
- master节点----x2 : 根据实际集群规模可以增加节点数，需要额外规划一个master VIP(虚地址)
- lb节点--------x2 : 负载均衡节点两个，安装 haproxy+keepalived
- node节点------x3 : 真正应用负载的节点，根据需要提升机器配置和增加节点数

***注意***

- 以上角色可以复用，但是保证集群稳定运行至少需要3台机器。

- etcd必须奇数个，一般规模的集群3个节点即可，过多影响性能。

## 4.2 部署节点安装依赖工具

```bash
yum install ansible -y
```

## 4.3 deploy节点编排k8s安装

### 4.3.1 获取项目代码并放置至/etc/ansible
```
wget 100.2.29.151/k8s_bin/icm-m_${build_tag}.tar.gz

```

解压并重命名文件至/etc/ansible下

### 4.3.3 准备 registry 镜像
准备离线仓库镜像文件，这个文件提供了部署kubernetes集群必要的images

```
tar zxvf registry_0.5.1.7.tar.gz -C /var/lib/registry/
```

## 4.4 配置集群参数

### 4.4.1 配置集群
```
cd /etc/ansible && cp example/hosts.m-masters.example hosts
```

然后根据实际情况修改此hosts文件

如果要部署allinone环境
```
cd /etc/ansible && cp example/hosts.allinone.example hosts

```

### 4.4.2 验证 ansible 安装
验证ansible及服务器通信状态，正常能看到节点返回 SUCCESS

```
ansible all -m ping
```

## 4.5 部署集群
这里建议分步部署，方便遇到异常排错

```
# 分步安装
ansible-playbook 01.prepare.yml
ansible-playbook 02.etcd.yml
ansible-playbook 03.docker.yml
ansible-playbook 04.kube-master.yml
ansible-playbook 05.kube-node.yml

# 如果有外部仓库不要部署
ansible-playbook 06.registryv2.yml

# 网络插件及addons
ansible-playbook 07.network.yml
ansible-playbook 08.cluster-addon.yml


```

一步安装:
```
ansible-playbook 90.setup.yml

```

***注意:***

如果这里只有master节点或者想让master开启调度，那么需要取消master污点，使其可调度pod：

```
kubectl patch node 节点1 节点2 节点3  -p '{"spec": {"unschedulable": false}}'

或者 
kubectl uncordon 节点

```


## 4.7 验证集群

通过 ***kubectl get pod*** 查看pod状态，
```bash
# kubectl get pod --all-namespaces -owide
NAMESPACE     NAME                                    READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE
kube-system   coredns-56684f94d6-89q9c                1/1     Running   7          16m   172.20.1.2    100.2.28.82   <none>
kube-system   coredns-56684f94d6-pww4b                1/1     Running   7          16m   172.20.0.2    100.2.28.81   <none>
kube-system   kube-flannel-ds-7b76k                   1/1     Running   0          12h   100.2.28.82   100.2.28.82   <none>
kube-system   kube-flannel-ds-gjlsr                   1/1     Running   0          12h   100.2.28.83   100.2.28.83   <none>
kube-system   kube-flannel-ds-t659z                   1/1     Running   0          12h   100.2.28.81   100.2.28.81   <none>
kube-system   kubernetes-dashboard-69dcdb65fd-9szv2   1/1     Running   0          15m   172.20.0.3    100.2.28.81   <none>
kube-system   metrics-server-868fdcf88c-wglfw         1/1     Running   0          15m   172.20.2.2    100.2.28.83   <none>


```

# 5 持久化存储

持久化存储可有多种选择，barematal环境中我们可以使用glusterfs、ceph、nfs等

## 5.1 glusterfs 对接

## 5.2 ceph rbd 对接
待补充

## 5.3 local volume
使用本地存储

## 5.3 nfs 对接(仅限于测试场景)

***不建议生产环境使用此种方式。***

### 5.3.1 准备nfs server

roles\cluster-storage\defaults\main.yml参数设置:

nfs.server_enabled 设置为yes(默认值)

### 5.3.2 部署nfs server 及 provisioner

```
ansible-playbook roles/cluster-storage/cluster-storage.yml -v

```

### 5.3.3 尝试设置为默认sc
默认情况下nfs server部署不是默认的sc(避免生产环境下数据误写入nfs)，需要修改为默认值：

修改为 metadata/annotations/storageclass.beta.kubernetes.io/is-default-class: "true" ,示例如下：

```
# kubectl edit sc nfs-dynamic-class
...
metadata:
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
...
```

查看nfs sc信息（default字样）：
```
# kubectl get sc
NAME                          PROVISIONER          AGE
nfs-dynamic-class (default)   nfs-provisioner-01   25m
```
# 6 cmp 及单 region 部署

***至此建议重新启动一个shell终端窗口, 避免有时部署结束k8s, bash 变量未生效问题!***

```
ansible-playbook 30.icm-deploy.yml
```
如果只部署指定模块:
```
ansible-playbook 30.icm-deploy.yml --tags=icinder,icompute,imonitor

```

如果需要跳过指定模块:

```
ansible-playbook 30.icm-deploy.yml --skip-tags=icinder,icompute,imonitor
```

# 7 多 region 部署
待补充

# 9 问题处理

## 9.1 外部访问中间件
部署之后，中间件及数据库默认是 *** ClusterIP *** ，用于集群内部通信，外部无法访问，方便调试，可以临时添加一个nodeport类型的service，映射到外部端口：

以influxdb为例(根据实际情况修改metadata及ports等信息)：

```
[root@haproxy01 devops]# cat influxdb-nodeport.yaml 
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.openshift.io/infrastructure: 'true'
  name: influxdb-influxdb-ingress
spec:
  ports:
    - name: api
      port: 8086
      protocol: TCP
      targetPort: 8086
    - name: rpc
      port: 8088
      protocol: TCP
      targetPort: 8088
  selector:
    name: influxdb-influxdb
  type: NodePort


```
编辑完成之后：

```
kubectl apply -f influxdb-nodeport.yaml 

```

查看映射端口：

```
[root@haproxy01 devops]# kubectl get svc
NAME                                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
redis                                  ClusterIP   172.30.94.147    <none>        6379/TCP                        17d
redis-ingress                          NodePort    172.30.77.253    <none>        6379:30597/TCP                  17d


```

这是会多一个type为NodePort的service，这是可用通过任意主机ip+30597访问redis。

完成之后delete

```
kubectl delete -f influxdb-nodeport.yaml 

```



另附 galera 示例：
```
[root@icm01 ~]# cat galera-nodeport.yaml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mysql
  name: galera-frontend
spec:
  ports:
  - name: mysql
    port: 3306
    protocol: TCP
    targetPort: 3306
  selector:
    app: mysql
  type: NodePort

```

## 9.2 coredns 无法启动
```
[root@icm02 images]# kubectl logs -f  coredns-5ccb5b96d9-jv694 -n kube-system
.:53
2019/03/18 02:53:27 [INFO] CoreDNS-1.2.2
2019/03/18 02:53:27 [INFO] linux/amd64, go1.11, eb51e8b
CoreDNS-1.2.2
linux/amd64, go1.11, eb51e8b
2019/03/18 02:53:27 [INFO] plugin/reload: Running configuration MD5 = afbaa991cc09b91b885a205d9b1a451b
2019/03/18 02:53:33 [FATAL] plugin/loop: Seen "HINFO IN 3894648066224133297.2261157047194500595." more than twice, loop detected

```
这里需要需改/etc/resolv.conf

## 9.3 修改 incloudmanager-config config 问题
有时候修改配置后，重启对应模块服务，配置不生效，这可能是 incloudmanager-config service 热更新失败。
那么可以手动重启 incloudmanager-config service。
```
kubectl delete incloudmanager-config-5554b87d8f-bkrb7
```
会自动重新启动新的incloudmanager-config服务

## 9.4 dashboard获取登录token

```
kubectl -n kube-system describe secrets $(kubectl  -n kube-system get secrets |grep admin-user|awk '{print $1}')

```
如果chrome提示 ***NET:ERR_CERT_INVALID***

这是服务器无法签发证书可以配置chrome绕过,chrome-属性-目标：

```
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --disable-infobars --ignore-certificate-errors

```

附：

基础环境依赖包,系统镜像中包含:
```
- conntrack-tools     # ipvs 模式需要
- psmisc        # 安装psmisc 才能使用命令killall，它在keepalive的监测脚本中使用到
- nfs-utils     # 挂载nfs 共享文件需要 (创建基于 nfs的PV 需要)
- jq                  # 轻量JSON处理程序，安装docker查询镜像需要
- socat               # 用于port forwarding
- bash-completion     # bash命令补全工具，需要重新登录服务器生效
- rsync               # 文件同步工具，分发证书等配置文件需要
- ipset
- ipvsadm

- haproxy
- keepalived
```
