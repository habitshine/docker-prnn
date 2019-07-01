docker-compose down
rm -rf data/
docker rmi maiyuan-master_postgres-master
docker rmi maiyuan-master_postgres-slave
docker rmi maiyuan-master_egg-master
#docker-compose up --build

