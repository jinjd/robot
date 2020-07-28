这里罗列了 TODO list
- [x] k8s 部署
    - [x] 集群
    - [x] allinone环境

- [ ] registry
    - [x] 单节点
    - [ ] HA

        k8s 容器调度，要确保registry高可用，保证pod调度后可正确拉取到images。
        
        *** 首先 实现单节点部署 registry v2 ***

- [x] helm 部署


- [x] 中间件部署/测试

    - [x] rabbitmq 
    - [x] redis-ha 哨兵模式
    - [x] influxdb 单副本，开源无集群
    - [x] mariadb-cluster 非helm部署方式，可靠性待驗證
    - [x] zookeeper

- [ ] helm 编排部署icm组件

    - [x] 單region部署实现
    - [ ] 多region部署实现
    
- [ ] 数据库创建

    iapps
    ibase
    icharge
    ihybrid
    ilifecycle
    imonitor
    ipaas
    iphymachine
    ireport
    iresource
    iworkflow

    db设置统一字符集utf8，排序规则utf8_bin

- [ ] images tag release
    
    归档发版镜像

        1. retag latest 当前版本号
        2. push images > registry v2
        3. 归档 registry

- [x] 移除icm-k8s-deploy项目
    
    迁移项目到本项目manifests下




- [ ] icm 容器日志处理

    几种选择

    - sidcar

    - 本地日志

- [ ] 其他
    - [ ] cronjob
    - [ ] sidcar 数据脚本
