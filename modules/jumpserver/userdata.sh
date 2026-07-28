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
APT_OPTS=(
  "-o" "Acquire::ForceIPv4=true"
  "-o" "Acquire::Retries=6"
  "-o" "Acquire::http::Timeout=30"
  "-o" "Acquire::https::Timeout=30"
)

retry() {
  local attempts="$1"
  local sleep_seconds="$2"
  shift 2

  local try=1
  while true; do
    if "$@"; then
      return 0
    fi

    if [ "$try" -ge "$attempts" ]; then
      echo "Command failed after $try attempts: $*"
      return 1
    fi

    echo "Command failed (attempt $try/$attempts): $*"
    echo "Retrying in ${sleep_seconds}s..."
    sleep "$sleep_seconds"
    try=$((try + 1))
  done
}

CPU_COUNT="$(nproc)"
MEMORY_MB="$(awk "/MemTotal/ {print int(\$2/1024)}" /proc/meminfo)"
echo "Detected resources: $CPU_COUNT vCPU, $MEMORY_MB MiB RAM"
if [ "$CPU_COUNT" -lt 4 ] || [ "$MEMORY_MB" -lt 8192 ]; then
  echo "Warning: JumpServer official quick install recommends at least 4 vCPU and 8 GiB RAM. Current instance may fail to install or run unstably."
fi

retry 12 10 apt-get "${APT_OPTS[@]}" update -y
retry 12 10 apt-get "${APT_OPTS[@]}" install -y ca-certificates curl wget tar iptables gettext

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
