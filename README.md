# AWS EKS 基础设施自动化部署 (Terraform)

本项目使用 Terraform 在 AWS 上自动化部署一个完整的 Kubernetes (EKS) 环境。

## 项目架构

该项目主要包含以下组件：

1.  **VPC Module**: 创建定制化的网络环境，包括公有子网、私有子网及其路由配置。
2.  **EKS Module**: 部署 AWS 托管的 Kubernetes 集群，置于私有子网内以确保安全。
3.  **Kubectl Server Module**: 部署一台位于公有子网的 EC2 实例，作为管理节点，预配置了访问 EKS 集群所需的权限。

## 目录结构

```text
.
├── main.tf            # 核心逻辑：调用各个模块
├── variable.tf        # 输入变量定义
├── providers.tf       # AWS Provider 配置
├── versions.tf        # Terraform 与 Provider 版本约束
└── modules/           # 模块定义 (vpc, eks, kubectl_server)
```

## 准备工作

1.  **安装 Terraform**: 版本需 >= `1.6.0`。
2.  **AWS 凭证**: 配置好本地的 AWS CLI 凭证，且具有创建 VPC、EKS 和 EC2 的权限。
3.  **SSH 密钥**: 准备好你的 SSH 公钥，用于访问管理服务器。

## 快速开始

### 1. 配置变量

在根目录下创建一个 `terraform.tfvars` 文件，并提供 `public_key`（用于 SSH 登录管理服务器）：

```hcl
public_key = "ssh-rsa AAAAB3Nza...你的公钥内容..."
aws_region = "ap-east-1"
```

### 2. 初始化与部署

```bash
# 初始化模块和插件
terraform init

# 查看执行计划
terraform plan

# 执行部署
terraform apply
```

### 3. 访问集群

部署完成后，Terraform 会输出管理服务器的公有 IP：

```bash
ssh -i /path/to/your/private_key ec2-user@<kubectl_server_public_ip>
```

## 清理资源

```bash
terraform destroy
```