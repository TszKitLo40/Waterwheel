function print_help {
    echo "help info:"
    echo "-p" namenode_host
    echo "-m" master/slave
    exit 0
}

while getopts hp:m: option
do
    case "${option}"
    in
      h) print_help;;
      p) NAMENODE_HOST=${OPTARG};;
      m) MODE=${OPTARG};;
    esac
done

if [ -z $NAMENODE_HOST ]; then
    echo "please specify the master node host"
    print_help
    exit 0
else
    echo "namenode host is $NAMENODE_HOST"
fi

if [ -z $MODE ]; then
    echo "please specify the node type: master/slave"
    print_help
    exit 0
fi

if [ ! "$MODE" = "slave" ] && [ ! "$MODE" = "master" ]; then
    echo "parameter -m must be either slave or master"
    exit 0
fi

if [ ! -f apache-storm-1.1.0.tar.gz ]; then
    wget http://www-us.apache.org/dist/storm/apache-storm-1.1.0/apache-storm-1.1.0.tar.gz
fi

tar xzf apache-storm-1.1.0.tar.gz

cp -f default-config/storm.yaml apache-storm-1.1.0/conf/

sed -i "s/master-host/$NAMENODE_HOST/g" apache-storm-1.1.0/conf/storm.yaml

sudo apt install python -y

if [ "$MODE" = "master" ]; then
    nohup apache-storm-1.1.0/bin/storm nimbus > apache-storm-1.1.0/bin/nimbus.log & 
    nohup apache-storm-1.1.0/bin/storm ui > apache-storm-1.1.0/bin/ui.log & 
fi

nohup apache-storm-1.1.0/bin/storm supervisor > apache-storm-1.1.0/bin/supervisor.log & 
