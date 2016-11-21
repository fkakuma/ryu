#!/bin/bash
set -xe

sudo mkdir -p /opt/stack
sudo chown -R travis:travis /opt/stack
export STACK_USER=stack
pushd ../
ROOTDIR=`pwd`
popd
export BASE=/opt/stack
BASEDIR=$BASE/new
mkdir -p $BASEDIR
pushd $BASEDIR
SUDO_EXEC="sudo -H -u stack"

sudo pip install -U tox
git clone https://git.openstack.org/openstack-dev/devstack
cd devstack

cat << EOF > localrc
GATE_STACK_USER=$STACK_USER
Q_USE_DEBUG_COMMAND=True
NEUTRON_CREATE_INITIAL_NETWORKS=False
NETWORK_GATEWAY=10.1.0.1
USE_SCREEN=False
DEST=$BASEDIR
# move DATA_DIR outside of DEST to keep DEST a bit cleaner
DATA_DIR=$BASE/data
ACTIVE_TIMEOUT=90
BOOT_TIMEOUT=90
ASSOCIATE_TIMEOUT=60
TERMINATE_TIMEOUT=60
MYSQL_PASSWORD=secretmysql
DATABASE_PASSWORD=secretdatabase
RABBIT_PASSWORD=secretrabbit
ADMIN_PASSWORD=secretadmin
SERVICE_PASSWORD=secretservice
SERVICE_TOKEN=111222333444
SWIFT_HASH=1234123412341234
ROOTSLEEP=0
# ERROR_ON_CLONE should never be set to FALSE in gate jobs.
# Setting up git trees must be done by zuul
# because it needs specific git references directly from gerrit
# to correctly do testing. Otherwise you are not testing
# the code you have posted for review.
ERROR_ON_CLONE=False
ENABLED_SERVICES=c-api,c-bak,c-sch,c-vol,ceilometer-acentral,ceilometer-acompute,ceilometer-alarm-evaluator,ceilometer-alarm-notifier,ceilometer-anotification,ceilometer-api,ceilometer-collector,cinder,dstat,g-api,g-reg,horizon,key,mysql,n-api,n-cond,n-cpu,n-crt,n-obj,n-sch,q-agt,q-dhcp,q-l3,q-meta,q-metering,q-svc,quantum,rabbit,s-account,s-container,s-object,s-proxy,tempest,tls-proxy
SKIP_EXERCISES=boot_from_volume,bundle,client-env,euca
SERVICE_HOST=127.0.0.1
# Screen console logs will capture service logs.
SYSLOG=False
SCREEN_LOGDIR=$BASEDIR/screen-logs
LOGFILE=$BASEDIR/devstacklog.txt
VERBOSE=True
FIXED_RANGE=10.1.0.0/20
FLOATING_RANGE=172.24.5.0/24
PUBLIC_NETWORK_GATEWAY=172.24.5.1
FIXED_NETWORK_SIZE=4096
VIRT_DRIVER=libvirt
SWIFT_REPLICAS=1
LOG_COLOR=False
# Don't reset the requirements.txt files after g-r updates
UNDO_REQUIREMENTS=False
CINDER_PERIODIC_INTERVAL=10
export OS_NO_CACHE=True
CEILOMETER_BACKEND=mysql
LIBS_FROM_GIT=
DATABASE_QUERY_LOGGING=True
# set this until all testing platforms have libvirt >= 1.2.11
# see bug #1501558
EBTABLES_RACE_FIX=True
CINDER_SECURE_DELETE=False
CINDER_VOLUME_CLEAR=none
LIBVIRT_TYPE=qemu
VOLUME_BACKING_FILE_SIZE=24G
TEMPEST_HTTP_IMAGE=http://git.openstack.org/static/openstack.png
FORCE_CONFIG_DRIVE=False
EOF

sudo tools/create-stack-user.sh
sudo chown -R $STACK_USER:$STACK_USER /opt/stack
$SUDO_EXEC ./stack.sh
$SUDO_EXEC ./unstack.sh
cd ../neutron
export INSTALL_MYSQL_ONLY=True
bash -xe $BASEDIR/neutron/neutron/tests/contrib/gate_hook.sh dsvm-fullstack
bash -xe $BASEDIR/neutron/neutron/tests/contrib/post_test_hook.sh dsvm-fullstack
popd
