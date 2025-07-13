# terraform-aws

## 必要なもの

- Docker
- AWSアカウントおよび設定済みの認証情報（`~/.aws/credentials`）

## セットアップ手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/Yutahhhhh/terraform-aws.git
cd terraform-aws
```

### 2. 環境変数の設定

プロジェクトで利用する環境変数を設定します。`.env.example`をコピーして`.env`ファイルを作成してください。

```bash
cp .env.example .env
```

作成した`.env`ファイルを開き、`TF_VAR_project_name`と`AWS_REGION`をあなたの環境に合わせて編集します。

```env
# アプリケーション名（S3バケット名などに利用）
TF_VAR_project_name=myapp

# AWSリージョン
AWS_REGION=ap-northeast-1
```

### 3. Terraformバックエンドの準備

Terraformのリモートステートを管理するためのS3バケットとDynamoDBテーブルを作成します。

```bash
chmod +x setup.sh
./setup.sh
```

このスクリプトを実行すると、`.env`ファイルの設定に基づいた名前でリソースが作成され、Terraformが参照するバックエンド設定ファイル (`terraform/backend.hcl`) が自動で生成されます。

## Terraformの実行手順

TerraformコマンドはすべてDockerコンテナ内で実行します。

### 1. Dockerコンテナの起動

まず、Dockerイメージをビルドし、コンテナを起動します。

```bash
# イメージのビルド（初回のみ or Dockerfile変更時）
docker-compose build

# コンテナを起動し、中に入る
docker-compose run --rm terraform
```

これ以降のTerraformコマンドは、起動したコンテナ内で実行してください。

### 2. Terraformの初期化

作業ディレクトリを`terraform`に移動し、`init`コマンドを実行してTerraformを初期化します。

```bash
# コンテナ内で実行
cd terraform
terraform init -backend-config=backend.hcl
```

### 3. 実行計画の確認

どのようなインフラが作成・変更されるかを確認します。

```bash
# コンテナ内で実行
terraform plan
```

### 4. インフラの構築・適用

計画に問題がなければ、インフラを実際に構築します。

```bash
# コンテナ内で実行
terraform apply
```

### 5. インフラの破棄

作成したインフラをすべて削除する場合は、以下のコマンドを実行します。

```bash
# コンテナ内で実行
terraform destroy
```

## インフラ依存関係の出力

リソースの依存関係をDOT言語形式で出力するスクリプトを用意しています。ファイル名は現在のGitブランチ名に基づいて自動で生成されます。

**前提:**
- `terraform init`が完了していること。

以下のコマンドをプロジェクトのルートディレクトリで実行してください。

```bash
# Dockerコンテナ内でスクリプトを実行し、依存関係グラフを生成します
docker-compose run --rm terraform ./graph.sh
```

実行後、`docs`ディレクトリに`[ブランチ名]_dependency-graph.dot`という名前でファイルが出力されます。

## リソースのクリーンアップ

### 1. Terraformリソースの削除

上記の手順で`terraform destroy`を実行してください。

### 2. バックエンドリソースの削除

`setup.sh`で作成したS3バケットとDynamoDBテーブルを削除します。

**注意:** この操作はTerraformのステートファイルを完全に削除します。実行には十分ご注意ください。

```bash
chmod +x cleanup.sh
./cleanup.sh
```

AIで出力しているので、文章の表現に違和感がある場合があります。