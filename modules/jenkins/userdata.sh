#!/bin/bash
set -euo pipefail

# ── 安装 Docker + Compose plugin ─────────────────────────
dnf install -y docker docker-compose-plugin
systemctl enable --now docker

# ── 创建宿主机目录 ────────────────────────────────────────
mkdir -p /data/jenkins_home
mkdir -p /data/compose
chown -R 1000:1000 /data/jenkins_home

# ── 写入 docker-compose.yaml ──────────────────────────────
cat > /data/compose/docker-compose.yaml << 'EOF'
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    user: "1000:1000"
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - /data/jenkins_home:/var/jenkins_home
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