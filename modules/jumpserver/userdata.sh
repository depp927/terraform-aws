#!/bin/bash
set -euo pipefail

# EC2 user_data is executed by cloud-init as root.
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

trap 'status=$?; echo "jumpserver user_data failed with exit code $status on line $LINENO"; touch /var/lib/jumpserver-userdata.failed; exit $status' ERR

touch /var/lib/jumpserver-userdata.started

export DEBIAN_FRONTEND=noninteractive

INSTALLER_VERSION="v4.10.17"
INSTALLER_DIR="/opt/jumpserver-installer-$INSTALLER_VERSION"

CPU_COUNT="$(nproc)"
MEMORY_MB="$(awk "/MemTotal/ {print int(\$2/1024)}" /proc/meminfo)"
echo "Detected resources: $CPU_COUNT vCPU, $MEMORY_MB MiB RAM"
if [ "$CPU_COUNT" -lt 4 ] || [ "$MEMORY_MB" -lt 8192 ]; then
  echo "Warning: JumpServer official quick install recommends at least 4 vCPU and 8 GiB RAM. Current instance may fail to install or run unstably."
fi

apt-get update -y
apt-get install -y ca-certificates curl wget tar iptables gettext

cd /opt
if [ ! -d "$INSTALLER_DIR" ]; then
  if ! wget -qO "jumpserver-installer-$INSTALLER_VERSION.tar.gz" \
    "https://resource.fit2cloud.com/jumpserver/installer/releases/download/$INSTALLER_VERSION/jumpserver-installer-$INSTALLER_VERSION.tar.gz"; then
    wget -qO "jumpserver-installer-$INSTALLER_VERSION.tar.gz" \
      "https://github.com/jumpserver/installer/releases/download/$INSTALLER_VERSION/jumpserver-installer-$INSTALLER_VERSION.tar.gz"
  fi

  tar -zxf "jumpserver-installer-$INSTALLER_VERSION.tar.gz"
  rm -f "jumpserver-installer-$INSTALLER_VERSION.tar.gz"
fi

chmod +x "$INSTALLER_DIR/jmsctl.sh"
"$INSTALLER_DIR/jmsctl.sh" install
"$INSTALLER_DIR/jmsctl.sh" start

touch /var/lib/jumpserver-userdata.completed
