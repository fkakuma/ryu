#!/bin/bash
set -xe

if [ -z $USER ]; then
    USER=travis
fi
DIR_PATH=`dirname $0`
pushd $DIR_PATH
SCRIPT_PATH=`pwd`
popd
export STACK_USER=stack
SUDO_EXEC="sudo -H -u $STACK_USER"
export BASE=/opt/stack
BASEDIR=$BASE/new
sudo mkdir -p $BASEDIR
sudo chown -R $USER:root $BASE

sudo apt-get update
sudo apt-get install -qy patch

pushd $BASEDIR
sudo pip install -U tox
git clone https://git.openstack.org/openstack-dev/devstack
git clone https://git.openstack.org/openstack/neutron

pushd neutron
patch -p1 < $SCRIPT_PATH/no-pg.patch
popd

sudo $BASEDIR/devstack/tools/create-stack-user.sh
#sudo chown -R $STACK_USER:$STACK_USER /opt/stack
popd

sudo chown -R $STACK_USER:$STACK_USER $BASE
$SUDO_EXEC bash -xe $DIR_PATH/fullstack_gate.sh
