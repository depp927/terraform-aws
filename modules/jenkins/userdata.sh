#!/bin/bash
set -euo pipefail

# ── 安装 Docker + Compose plugin ─────────────────────────
sudo dnf install -y docker
sudo mkdir -p /usr/local/lib/docker/cli-plugins
 sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
sudo systemctl enable --now docker

# ── 创建宿主机目录 ────────────────────────────────────────
sudo mkdir -p /data/jenkins_home
sudo mkdir -p /data/compose
#sudo chown -R 1000:1000 /data/jenkins_home

# ── 写入 docker-compose.yaml ──────────────────────────────
sudo sh -c "cat > /data/compose/docker-compose.yaml" << 'EOF'
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    user: "0:0"
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - /data/jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
      - /usr/libexec/docker/cli-plugins:/usr/libexec/docker/cli-plugins
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=true
EOF

# ── 启动 Jenkins ──────────────────────────────────────────
docker compose -f /data/compose/docker-compose.yaml up -d

# ── 等待初始密码生成后写入日志 ────────────────────────────
for i in {1..30}; do
  if [ -f /data/jenkins_home/secrets/initialAdminPassword ]; then
    echo "Jenkins initial password: $(cat /data/jenkins_home/secrets/initialAdminPassword)"
    break
  fi
  sleep 10
done