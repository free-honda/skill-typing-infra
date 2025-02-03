## 【AWS インフラストラクチャ構築（Terraform）】
このリポジトリでは、Terraform を使用して AWS 上にインフラを構築するためのコードを提供します。

### 🛠 必要なツール
このコードを実行する前に、以下のツールをインストールしてください。

- Terraform  
- AWS CLI

また、`aws configure` を実行し、AWS のクレデンシャルを設定してください。

```bash
aws configure
```

### ⚠️ 注意点
- **ACM 証明書の変更**

別の証明書を使用する場合は、ARN を設定してください。
```bash
# ACM 証明書の ARN（外部入力用）
variable "acm_certificate_arn" {
  default     = "arn:aws:acm:ap-northeast-1:881490128743:certificate/d4cd488c-2252-489a-8011-87239ddb1ac7"
  description = "ARN of the ACM Certificate"
}
```

- **ECS コンテナイメージの変更**

自分の ECR リポジトリを使用する場合は、以下の箇所を変更してください。
```bash
image = "YOUR_ECR_REPO_URL"
```

- **RDS のパスワード変更**

RDS のパスワードは AWS Secrets Manager で管理されています。デフォルトでは `rds_password_v2` という名前のシークレットが作成されます。
別の名前に変更する場合は、以下のように設定してください。
```bash
resource "aws_secretsmanager_secret" "rds_password_custom" {
  name = "your-custom-rds-password"
}
```

### 🚀 デプロイ手順
**1. リポジトリのクローン**  
```bash
git clone https://github.com/Winter-Hackathon-2025-A-Team/skill-typing-infra.git
cd skill-typing-infra
```

**2. Terraform の初期化**

Terraform のプラグインをダウンロードし、初期化を行います。
```bash
terraform init
```

**3. リソースの適用**

Terraform を適用し、インフラをデプロイします。
```bash
terraform apply
```

**4. リソースの削除**

作成したリソースを削除する場合は、以下のコマンドを実行してください。
```bash
terraform destroy
```

### 📌 構築するインフラ

VPC（Virtual Private Cloud）
- AWS 上で独立したネットワーク環境を構築
- CIDR ブロックの指定
- サブネットの分割（パブリック / プライベート）

サブネット
- **パブリックサブネット**：インターネットへのアクセスが可能
- **プライベートサブネット**：インターネットからの直接アクセスを制限

インターネットゲートウェイ / NAT ゲートウェイ
- **インターネットゲートウェイ（IGW）**：パブリックサブネットからの外部通信を許可
- **NAT ゲートウェイ**：プライベートサブネットからの外部通信を許可

ECS（Elastic Container Service）
- AWS Fargate によるコンテナ管理
- タスク定義（Task Definition）の作成
- サービスのデプロイ（ECS Service）
- ALB（Application Load Balancer）との統合

ALB（Application Load Balancer）
- ECS サービスのロードバランシング
- **ターゲットグループ** の設定
- **リスナー** の設定（HTTP / HTTPS）
- **ヘルスチェック** の構成

RDS（Relational Database Service）
- MySQL 8.0 のデータベースを作成
- **パラメータグループ** の設定
- **セキュリティグループ** によるアクセス制御
- **Secrets Manager** によるパスワード管理

CloudFront & S3

S3（Simple Storage Service）
- React アプリのホスティング
- **バケットポリシー** の設定
- **OAI（Origin Access Identity）** によるアクセス制御

CloudFront（CDN）
- S3 をオリジンとしたコンテンツ配信
- **キャッシュポリシー** の設定
- **カスタムドメイン**（オプション）

### 💬 問い合わせ
質問や問題がある場合は、GitHub の Issues または Pull Request でお問い合わせください。
