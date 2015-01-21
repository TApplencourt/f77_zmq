#!/bin/bash
#
# Tests the build distribution


ZMQ_TGZ="zeromq-4.0.5.tar.gz"


export C_INCLUDE_PATH=${C_INCLUDE_PATH}:./

mkdir -p _build
pushd _build

# Download ZeroMQ library
# =======================

if [[ ! -f ${ZMQ_TGZ} ]]
then
   wget "http://download.zeromq.org/"${ZMQ_TGZ}
   if [[ $? -ne 0 ]]
   then
      echo "Unable to download ${ZMQ_TGZ}"
      exit 1
   fi
fi

# Install ZeroMQ library
# ======================

mkdir lib

tar -zxf ${ZMQ_TGZ}
pushd ${ZMQ_TGZ%.tar.gz}
./configure || exit 1
make || exit 1
#cp src/.libs/libzmq.a ../lib
cp src/.libs/libzmq.so ../lib/libzmq.so.4
cp include/{zmq.h,zmq_utils.h} ../lib
popd
pushd lib
ln -s libzmq.so.4 libzmq.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD
export LIBRARY_PATH=$LIBRARY_PATH:$PWD
export ZMQ_H=$PWD/zmq.h
popd
popd

# Build library and examples
# ==========================

make || (ls ; exit 1)
pushd examples
FC="gfortran -g -O2 -fopenmp"
make || (ls ; exit 1)


# Run tests
# =========

cat << EOF > ref1 
 msg_copy_from/to
 Received :Hello!
 msg_copy
 msg_new/destroy_data
 Received :Hello!
 msg_copy_from/to
 Received :Hello!
 msg_copy
 msg_new/destroy_data
 Received :Hello!
 msg_copy_from/to
 Received :Hello!
 msg_copy
 msg_new/destroy_data
 Received :Hello!
 msg_copy_from/to
 Received :Hello!
EOF

cat << EOF > ref2
           1 Received :World
           2 Received :Hello!
           3 Received :world
           4 Received :World
           5 Received :Hello!
           6 Received :world
           7 Received :World
           8 Received :Hello!
           9 Received :world
          10 Received :World
EOF

./hwserver_msg > hwserver_msg.out &
./hwclient_msg > hwclient_msg.out ;
wait

diff hwserver_msg.out ref1 || exit 1 
diff hwclient_msg.out ref2 || exit 1
