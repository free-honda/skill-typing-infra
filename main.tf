# AWSプロバイダーの設定（東京リージョン）
provider "aws" {
  region = "ap-northeast-1"
}

# ACM 証明書の ARN（外部入力用）
variable "acm_certificate_arn" {
  default     = "arn:aws:acm:ap-northeast-1:881490128743:certificate/d4cd488c-2252-489a-8011-87239ddb1ac7"
  description = "ARN of the ACM Certificate"
}

# VPC の定義
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform-vpc"
  }
}

# パブリックサブネット（AZ: ap-northeast-1a）
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "Terraform-subnet-public1-ap-northeast-1a"
  }
}

# パブリックサブネット（AZ: ap-northeast-1c）
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "Terraform-subnet-public2-ap-northeast-1c"
  }
}

# プライベートサブネット（AZ: ap-northeast-1a）
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "Terraform-subnet-private1-ap-northeast-1a"
  }
}

# プライベートサブネット（AZ: ap-northeast-1c）
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "Terraform-subnet-private2-ap-northeast-1c"
  }
}

# プライベートサブネット（AZ: ap-northeast-1a, 別のCIDRブロック）
resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.160.0/20"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "Terraform-subnet-private3-ap-northeast-1a"
  }
}

# プライベートサブネット（AZ: ap-northeast-1c, 別のCIDRブロック）
resource "aws_subnet" "private4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.176.0/20"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "Terraform-subnet-private4-ap-northeast-1c"
  }
}

# インターネットゲートウェイ（IGW）の定義（VPC のインターネット接続用）
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-igw"
  }
}

# パブリックルートテーブルの定義（パブリックサブネット用のルートテーブル）
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-rtb-public"
  }
}

# インターネットアクセス用のデフォルトルート（0.0.0.0/0 → IGW）
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# パブリックサブネットをルートテーブルに関連付け
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# NAT ゲートウェイ用の Elastic IP（プライベートサブネットのインターネットアクセス用）
resource "aws_eip" "nat" {
  tags = {
    Name = "Terraform-eip-ap-northeast-1a"
  }
}

# NAT ゲートウェイの定義（プライベートサブネットがインターネットにアクセスできるようにする）
resource "aws_nat_gateway" "public1" {
  subnet_id     = aws_subnet.public1.id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "Terraform-nat-public1-ap-northeast-1a"
  }
}

# プライベートルートテーブル（AZ: ap-northeast-1a）
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-rtb-private1-ap-northeast-1a"
  }
}

# プライベートルートの定義（NAT ゲートウェイ経由でインターネットアクセス）
resource "aws_route" "private1_nat_access" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

# プライベートサブネットをルートテーブルに関連付け
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

# プライベートルートテーブル（AZ: ap-northeast-1c）
resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-rtb-private2-ap-northeast-1c"
  }
}

# プライベートルートの定義（NAT ゲートウェイ経由でインターネットアクセス）
resource "aws_route" "private2_nat_access" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

# プライベートサブネットをルートテーブルに関連付け
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

# プライベートルートテーブル（AZ: ap-northeast-1a, 別のサブネット用）
resource "aws_route_table" "private3" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-rtb-private3-ap-northeast-1a"
  }
}

# プライベートルート（AZ: ap-northeast-1a, NAT ゲートウェイ経由でインターネットアクセス）
resource "aws_route" "private3_nat_access" {
  route_table_id         = aws_route_table.private3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

# プライベートサブネットをルートテーブルに関連付け（AZ: ap-northeast-1a）
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private3.id
}

# プライベートルートテーブル（AZ: ap-northeast-1c, 別のサブネット用）
resource "aws_route_table" "private4" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-rtb-private4-ap-northeast-1c"
  }
}

# プライベートルート（AZ: ap-northeast-1c, NAT ゲートウェイ経由でインターネットアクセス）
resource "aws_route" "private4_nat_access" {
  route_table_id         = aws_route_table.private4.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

# プライベートサブネットをルートテーブルに関連付け（AZ: ap-northeast-1c）
resource "aws_route_table_association" "private4" {
  subnet_id      = aws_subnet.private4.id
  route_table_id = aws_route_table.private4.id
}

# ECS 用のセキュリティグループ（アプリケーションの通信を制御）
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  # ALB からのリクエストを許可（ポート 1323）
  ingress {
    from_port       = 1323
    to_port         = 1323
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # すべてのアウトバウンドトラフィックを許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-private-instance-sg"
  }
}

# ECS クラスターの定義（Fargate でアプリを実行）
resource "aws_ecs_cluster" "main" {
  name = "my-ecs-cluster"
}

# ECS タスク実行ロールの定義（ECS タスクが必要な AWS サービスにアクセスするための IAM ロール）
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  # ECS タスクがこのロールを引き受けるためのポリシー
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  # タスク実行に必要な AWS サービスへのアクセス許可
  inline_policy {
    name = "ecs-task-execution-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "ecr:GetAuthorizationToken",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "s3:GetObject"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

# ECS タスク定義（Fargate で動作するコンテナの定義）
resource "aws_ecs_task_definition" "main" {
  family                   = "my-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name       = "my-app-repo"
      image      = "881490128743.dkr.ecr.ap-northeast-1.amazonaws.com/my-app-repo"
      portMappings = [
        {
          containerPort = 1323
          hostPort      = 1323
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ECS サービスの定義（Fargate で実行し、プライベートサブネットに配置）
resource "aws_ecs_service" "main" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # ネットワーク設定（プライベートサブネットで実行し、パブリック IP を付与しない）
  network_configuration {
    subnets         = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false # パブリック IP を付与せず、NAT 経由で通信
  }

  # ALB との接続設定（ECS タスクを ALB に登録）
  load_balancer {
    target_group_arn = aws_lb_target_group.main_target_group.arn
    container_name   = "my-app-repo"
    container_port   = 1323
  }
}

# パブリック（ALB）用セキュリティグループの定義（HTTPS トラフィックを許可）
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  # インバウンドルール: HTTPS (443) の受信を全インターネットから許可
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンドルール: すべての通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-public-sg"
  }
}

# アプリケーションロードバランサー（ALB）の定義（パブリックアクセス可能な ALB）
resource "aws_lb" "main_alb" {
  name               = "terraform-main-alb"
  internal           = false # パブリック ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id] # ALB に適用するセキュリティグループ
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id] # ALB の配置サブネット

  enable_deletion_protection = false # 削除保護を無効化

  tags = {
    Name = "terraform-main-alb"
  }
}

# ターゲットグループの定義（ALB がリクエストを転送する先）
resource "aws_lb_target_group" "main_target_group" {
  name     = "terraform-main-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip" # Fargate の場合は 'ip' に設定

  # ヘルスチェックの設定（ALB が正常なターゲットを判断する）
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  # セッション維持設定（ALB の負荷分散時にセッションを保持）
  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400
  }

  tags = {
    Name = "terraform-main-target-group"
  }
}

# ALB のリスナー設定（HTTPS リクエストをターゲットグループに転送）
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  
  certificate_arn = var.acm_certificate_arn # SSL 証明書の ARN を指定

  # ターゲットグループへのリクエスト転送設定
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_target_group.arn
  }
}

# RDS 用セキュリティグループ（データベースへのアクセスを制御）
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  # インバウンドルール: MySQL (3306) の接続を VPC 内のリソースから許可
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # アウトバウンドルール: すべての通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-rds-sg"
  }
}

# RDS 用サブネットグループの定義（RDS を配置するサブネットを指定）
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "terraform-rds-subnet-group"
  subnet_ids = [aws_subnet.private3.id, aws_subnet.private4.id]

  tags = {
    Name = "Terraform-rds-subnet-group"
  }
}

# Secrets Manager を使用して RDS のパスワードを管理
resource "aws_secretsmanager_secret" "rds_password_v2" {
  name = "rds_password_v2"
}

# Secrets Manager に保存する RDS のパスワード（初期設定）
resource "aws_secretsmanager_secret_version" "rds_password_version_v2" {
  secret_id     = aws_secretsmanager_secret.rds_password_v2.id
  secret_string = jsonencode({ password = "mypassword123" })
}

# Secrets Manager から RDS のパスワードを取得
data "aws_secretsmanager_secret_version" "rds_password_v2" {
  secret_id  = aws_secretsmanager_secret.rds_password_v2.arn
  depends_on = [aws_secretsmanager_secret_version.rds_password_version_v2]
}

# RDS インスタンスの定義（MySQL 8.0 を使用）
resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.39"
  instance_class       = "db.t4g.micro"
  username             = "admin"
  password             = jsondecode(data.aws_secretsmanager_secret_version.rds_password_v2.secret_string)["password"]

  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  multi_az            = false

  tags = {
    Name = "Terraform-rds-instance"
  }

  # 削除時の最終スナップショット作成をスキップ
  skip_final_snapshot = true
}

# S3 バケットの定義（CloudFront 経由でアクセスするためのバケット）
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-cloudfront-bucket-tokyo"
  acl    = "private" # バケットは非公開に設定（CloudFront からのアクセスのみ許可）

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Production"
  }
}

# S3 バケットのウェブホスティング設定（index.html と error.html を指定）
resource "aws_s3_bucket_website_configuration" "my_bucket_website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# CloudFront 用オリジンアクセスアイデンティティ（OAI）の定義（S3 へのセキュアなアクセスを許可）
resource "aws_cloudfront_origin_access_identity" "my_oai" {
  comment = "OAI for S3 bucket"
}

# S3 バケットポリシーの設定（CloudFront OAI のみ S3 へのアクセスを許可）
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.my_oai.iam_arn
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

# 簡易的な HTML ファイル（index.html）の作成
resource "local_file" "index_html" {
  content  = "<html><body><h1>React in S3</h1></body></html>"
  filename = "index.html"
}

# index.html を S3 バケットにアップロード
resource "aws_s3_object" "index_file" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = local_file.index_html.filename
  content_type = "text/html"
  acl          = "private" # オブジェクトは非公開（CloudFront 経由でのみアクセス可能）
}

# CloudFront ディストリビューションの定義（S3 バケットをオリジンとする）
resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = "S3-my-cloudfront-bucket"

    # CloudFront が S3 にアクセスするための OAI を設定
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.my_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true  # ディストリビューションを有効化
  is_ipv6_enabled     = true  # IPv6 を有効化
  comment             = "CloudFront Distribution for S3 bucket in Tokyo region"
  default_root_object = "index.html" # ルートにアクセスした際のデフォルトファイル

  # デフォルトのキャッシュ動作設定（GET/HEAD のみ許可し、HTTPS にリダイレクト）
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-my-cloudfront-bucket"

    forwarded_values {
      query_string = false # クエリパラメータをキャッシュのキーに含めない

      cookies {
        forward = "none" # クッキーを転送しない
      }
    }

    viewer_protocol_policy = "redirect-to-https" # HTTP を HTTPS にリダイレクト
  }

  # 地理的制限の設定（制限なし）
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # 料金クラスの設定（安価なリージョンのみ使用）
  price_class = "PriceClass_100"

  # CloudFront の SSL 証明書設定（デフォルトの CloudFront 証明書を使用）
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "MyCloudFrontDistribution"
    Environment = "Production"
  }
}
