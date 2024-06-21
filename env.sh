#
# Copyright 2024 Ant Group Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
OCCLUM_DEV_IMAGE=secretflow/trustedflow-dev-occlum-ubuntu22.04:latest
DEV_IMAGE=secretflow/trustedflow-dev-ubuntu22.04:latest
DOCKER=docker
PROJECT=capsule-manager-dev-ubuntu

SGX2_ENCLAVE_TREE_DEVICE="/dev/sgx/enclave"
SGX2_PROVISION_TREE_DEVICE="/dev/sgx/provision"

SGX2_ENCLAVE_DEVICE="/dev/sgx_enclave"
SGX2_PROVISION_DEVICE="/dev/sgx_provision"

TDX_DEVICE="/dev/tdx_guest"

CSV_DEVICE="/dev/csv-guest"

DOCKER_DEVICE_FLAGS=""
if [ -e "$SGX2_ENCLAVE_TREE_DEVICE" ] && [ -e "$SGX2_PROVISION_TREE_DEVICE" ]; then
DEV_IMAGE=${OCCLUM_DEV_IMAGE}
DOCKER_DEVICE_FLAGS="-v $SGX2_ENCLAVE_TREE_DEVICE:$SGX2_ENCLAVE_TREE_DEVICE -v $SGX2_PROVISION_TREE_DEVICE:$SGX2_PROVISION_TREE_DEVICE"
elif [ -e "$SGX2_ENCLAVE_DEVICE" ] && [ -e "$SGX2_PROVISION_DEVICE" ]; then
DEV_IMAGE=${OCCLUM_DEV_IMAGE}
DOCKER_DEVICE_FLAGS="-v $SGX2_ENCLAVE_DEVICE:$SGX2_ENCLAVE_DEVICE -v $SGX2_PROVISION_DEVICE:$SGX2_PROVISION_DEVICE"
elif [ -e "$TDX_DEVICE" ]; then
DOCKER_DEVICE_FLAGS="-v $TDX_DEVICE:$TDX_DEVICE"
elif [ -e "$CSV_DEVICE" ]; then
DOCKER_DEVICE_FLAGS="-v $CSV_DEVICE:$CSV_DEVICE"
fi

if [[ $1 == 'enter' ]]; then
    sudo $DOCKER exec -it ${PROJECT}-build-$(whoami) bash
else
    sudo $DOCKER run --name ${PROJECT}-build-$(whoami) -td \
        --net host \
        $DOCKER_DEVICE_FLAGS \
        -v $DIR:/home/admin/dev \
        -v /root/${USER}-${PROJECT}-bazel-cache-test:/root/.cache/bazel \
        -v /home/${USER}/projects/secure-data-capsule-apis:/home/admin/secure-data-capsule-apis \
        -w /home/admin/dev \
        --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
        --cap-add=NET_ADMIN \
        --privileged=true \
        ${DEV_IMAGE}
fi
