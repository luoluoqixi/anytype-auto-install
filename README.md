# anytype-auto-install

## anytype 自部署自动安装

### 用法

```
sudo sh ./install.sh
```

install.sh 会执行以下操作

1. 自动检测 docker buildx 是否安装, 如果没有安装则自动安装

2. 自动拉取 any-sync-dockercompose 存储库到当前脚本同目录

3. 自动创建 storage 文件夹

4. 自动拷贝.env.override 到 any-sync-dockercompose

5. 自动执行 docker buildx build 生成网络配置

6. 自动执行 docker compose pull 拉取所需镜像

```
sudo sh ./start.sh
```

start.sh 自动执行 buildx 生成网络配置 + 启动容器

```
sudo sh ./stop.sh
```

stop.sh 自动删除容器（不清除数据）

```
sudo sh ./uninstall.sh
```

uninstall.sh 删除容器容器相关所有数据（包括 storage）

```
sudo sh ./backup.sh
```

backup.sh 自动拷贝 any-sync-dockercompose/etc、any-sync-dockercompose/storage 到 当前目录并压缩备份为 backup_xxx.zip
