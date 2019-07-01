echo 'Begin Setting Posgresql Master ...'
POSTGRESQL_CONF="$PGDATA/postgresql.conf"
mkdir -p "$PGDATA/pg_archive"
echo "host   replication      replica       172.20.0.3/16          trust" >> "$PGDATA/pg_hba.conf"
sed "s/#archive_mode = off/archive_mode = on/g" -i "$POSTGRESQL_CONF"  # 允许归档
sed "s/#archive_command = ''/archive_command = 'cp %p ${PGDATA//\//\\/}\/pg_archive\/%f'/g" -i "$POSTGRESQL_CONF" # 用该命令来归档logfile segment
sed "s/#wal_level = replica/wal_level = hot_standby/g" -i "$POSTGRESQL_CONF" # 开启热备
sed "s/#max_wal_senders = 10/max_wal_senders = 32/g" -i "$POSTGRESQL_CONF" # 这个设置了可以最多有几个流复制连接，差不多有几个从，就设置几个
sed "s/#wal_keep_segments = 0/wal_keep_segments = 64/g" -i "$POSTGRESQL_CONF" # 设置流复制保留的最多的xlog数目，一份是 16M，注意机器磁盘 16M*64 = 1G
sed "s/#wal_sender_timeout/wal_sender_timeout/g" -i "$POSTGRESQL_CONF" # 设置流复制主机发送数据的超时时间