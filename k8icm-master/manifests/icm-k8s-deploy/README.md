# icm 工程文件
移除jenkinsfile,将其移动至每个工程目录下

## 文件介绍

1. 文件夹
以项目区分，每个文件夹一个项目工程
2. 文件结构:

```bash
-rw-r--r-- 1 inspur 197121  869 11月 16 16:34 imirror.yaml

```

- yaml结尾的为k8s/openshift编排文件

 - 编排文件  
 - configmap文件(已经移除)

- jenkinsfile结尾的为Jenkinsfile


## incloudmanager-config

```bash
-rw-r--r-- 1 inspur 197121 10929 11月 16 15:24 icm-configmap.yaml
-rw-r--r-- 1 inspur 197121  1098 11月 16 16:27 incloudmanager-config-service.yaml

```

- configmap
 - 包含整个工程的config文件

# TODO
1. 自动化生成项目编排文件
2. 服务治理
