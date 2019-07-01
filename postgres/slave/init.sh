# 从库配置
echo 'Begin Setting Posgresql Slave ...'
# echo "删除DATA目录"
rm -rf $PGDATA  # 清除从库数据
# echo "开始还原数据..."
pg_basebackup -h 172.20.0.2 -U replica -D $PGDATA -X stream -P
# pg_basebackup -D $PGDATA -Fp -Xs -v -P -h 172.20.0.2 -U replica -W
# echo "还原结束..."
mkdir -p "$PGDATA/pg_archive"
echo "standby_mode = on" >> "$PGDATA/recovery.conf" # 说明该节点是从服务器
echo "primary_conninfo = 'host=172.20.0.2 port=5432 user=replica password=replica'" >> "$PGDATA/recovery.conf" # 主服务器的信息以及连接的用户
echo "recovery_target_timeline = 'latest'" >> "$PGDATA/recovery.conf"
# echo "配置文件OK..."
# cat "$PGDATA/recovery.conf"

sed "s/#wal_level = replica/wal_level = hot_standby/g" -i "$PGDATA/postgresql.conf" # 设置流复制主机发送数据的超时时间
sed "s/max_connections = 100/max_connections = 1000/g" -i "$PGDATA/postgresql.conf" # 一般查多于写的应用从库的最大连接数要比较大
sed "s/#hot_standby/hot_standby/g" -i "$PGDATA/postgresql.conf" # 说明这台机器不仅仅是用于数据归档，也用于数据查询
sed "s/#max_standby_streaming_delay = 30s/max_standby_streaming_delay = 30s/g" -i "$PGDATA/postgresql.conf" # 数据流备份的最大延迟时间
sed "s/#wal_receiver_status_interval = 10s/wal_receiver_status_interval = 10s/g" -i "$PGDATA/postgresql.conf" # 多久向主报告一次从的状态，当然从每次数据复制都会向主报告状态，这里只是设置最长的间隔时间
sed "s/#hot_standby_feedback = off/hot_standby_feedback = on/g" -i "$PGDATA/postgresql.conf" # 如果有错误的数据复制，是否向主进行反馈