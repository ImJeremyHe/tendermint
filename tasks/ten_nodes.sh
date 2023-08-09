ALL_OK=true
if [[ $1 = "stop" ]]; then
    kill -9 $(ps -ef | grep ten_nodes | awk '{print $2}')
    kill -9 $(ps -ef | grep mock_eth_rpc | awk '{print $2}')
    return
elif [[ $1 = "all_ok" ]]; then
    ALL_OK=true
else
    ALL_OK=false
fi

DIR=$( cd $( dirname $0 ); pwd)
WORKSPACE=$(dirname $DIR)

python3 $DIR/mock_eth_rpc.py > /dev/null 2>&1 &

if [ -d $DIR/ten_nodes ]; then
    rm -rf $DIR/ten_nodes
fi

mkdir $DIR/ten_nodes

# copy the config files for running a tendermint node
for i in {1..10}; do
    mkdir -p "$DIR/ten_nodes/node$i/config"
    mkdir "$DIR/ten_nodes/node$i/data"
    cp $DIR/config/config.toml $DIR/ten_nodes/node$i/config/config.toml
    cp $DIR/config/genesis.json $DIR/ten_nodes/node$i/config/genesis.json
    cp $DIR/config/node$i/* $DIR/ten_nodes/node$i/config
    mv $DIR/ten_nodes/node$i/config/priv_validator_key.json $DIR/ten_nodes/node$i/data

    let j=$i-1
    let rpc_laddr_port=26657+$j*120
    let p2p_laddr_port=26656+$j*120
    let proxy_app_port=26658+$j*120
    sed -i "" -e "s/:26657/:$rpc_laddr_port/g" -e "s#tcp://0.0.0.0:26656#tcp://0.0.0.0:$p2p_laddr_port#g" -e "s/:26658/:$proxy_app_port/g" $DIR/ten_nodes/node$i/config/config.toml
    # if [[ $i>1 ]]; then
    #     sed -i "" -e "s#seeds = \"\"#seeds = \"d2f91463c7357bb813ec336301dc7305fb455c94@127.0.0.1:26656\"#g" $DIR/ten_nodes/node$i/config/config.toml
    # fi
    if [[ !$ALL_OK && $i>5 ]]; then
        sed -i "" -e "s#127.0.0.1:8545/10000#127.0.0.1:8545/10001#g" $DIR/ten_nodes/node$i/config/config.toml
    fi
done

if [ -d $DIR/logs ]; then
    rm -rf $DIR/logs
fi

mkdir logs

# run the node
for i in {1..10}; do
    touch $DIR/logs/log$i.out
    sleep 1
    # make sure $GOPATH is in your environment
    go run $WORKSPACE/cmd/tendermint/main.go start --home $DIR/ten_nodes/node$i --proxy_app kvstore > $DIR/logs/log$i.out&
done