#!/bin/bash
# Original code from: https://github.com/firecracker-microvm/firectl#getting-started-on-aws
# Tested on Ubuntu 20.04 (LTS) x64, x86_64 architecture, AMD CPUs

set -ex # exit on error
cd ~
ARCH="$(uname -m)"

# Versions
# Firectl releases: https://github.com/firecracker-microvm/firectl/releases
# Firecracker releases: https://github.com/firecracker-microvm/firecracker/releases
FIRECTL_VERSION=v0.2.0
FIRECRACKER_VERSION=v1.3.3

# Update server
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes update
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes upgrade # press enter on any popups
sudo DEBIAN_FRONTEND=noninteractive apt-get --yes dist-upgrade

# Get firectl binary:
wget https://github.com/firecracker-microvm/firectl/releases/download/${FIRECTL_VERSION}/firectl-${FIRECTL_VERSION}
wget https://github.com/firecracker-microvm/firectl/releases/download/${FIRECTL_VERSION}/firectl-${FIRECTL_VERSION}.sha256
sha256sum -c firectl-${FIRECTL_VERSION}.sha256
chmod +x firectl-${FIRECTL_VERSION}
sudo mv firectl-${FIRECTL_VERSION} /usr/local/bin/firectl

# Get Firecracker binary:
wget https://github.com/firecracker-microvm/firecracker/releases/download/${FIRECRACKER_VERSION}/firecracker-${FIRECRACKER_VERSION}-${ARCH}.tgz
wget https://github.com/firecracker-microvm/firecracker/releases/download/${FIRECRACKER_VERSION}/firecracker-${FIRECRACKER_VERSION}-${ARCH}.tgz.sha256.txt
sha256sum -c firecracker-${FIRECRACKER_VERSION}-${ARCH}.tgz.sha256.txt
tar -xzf firecracker-${FIRECRACKER_VERSION}-${ARCH}.tgz
cd ./release-${FIRECRACKER_VERSION}-${ARCH}
sudo cp firecracker-${FIRECRACKER_VERSION}-${ARCH} /usr/local/bin/firecracker
sudo cp jailer-${FIRECRACKER_VERSION}-${ARCH} /usr/local/bin/jailer

# Give read/write access to KVM:
sudo apt-get install acl
sudo setfacl -m u:${USER}:rw /dev/kvm

# Download kernel and root filesystem:
curl -fsSL -o hello-vmlinux.bin https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin
curl -fsSL -o hello-rootfs.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/hello/fsfiles/hello-rootfs.ext4



echo "Installation Done."
printf "Test:\nfirectl --kernel=hello-vmlinux.bin --root-drive=hello-rootfs.ext4\n"