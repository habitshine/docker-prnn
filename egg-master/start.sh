if [ ! -d "./node_modules" ];then
	npm install -g cnpm --registry=https://registry.npm.taobao.org
	cnpm i
fi
exec $SCRIPT