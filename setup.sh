#!/bin/bash

# --- .envファイルの自動読み込み ---
# スクリプトと同じディレクトリにある .env ファイルを検索し、存在すれば読み込む
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
if [ -f "${SCRIPT_DIR}/.env" ]; then
  # `set -a` を使うと、sourceで読み込んだ変数が自動的にエクスポートされる
  set -a
  source "${SCRIPT_DIR}/.env"
  set +a
  echo "✅ .envファイルを読み込みました"
else
  echo "⚠️  .envファイルが見つかりません: ${SCRIPT_DIR}/.env"
fi

# --- .envファイルから環境変数が読み込まれます ---
# TF_VAR_project_name: アプリケーション名 (リソース名のプレフィックスとして使用)
# AWS_REGION: AWSリージョン
# AWS_PROFILE: AWSプロファイル（オプション）

# 必要な環境変数が設定されているかチェック
: "${TF_VAR_project_name?エラー: 環境変数 TF_VAR_project_name が設定されていません。.envファイルで定義してください。}"
: "${AWS_REGION?エラー: 環境変数 AWS_REGION が設定されていません。.envファイルで定義してください。}"

# リソース名を自動生成
BUCKET_NAME="${TF_VAR_project_name}-terraform-state"
DYNAMODB_TABLE_NAME="${TF_VAR_project_name}-terraform-state-locks"

# AWSコマンドのラッパー関数を定義
# AWS_PROFILEが設定されていれば --profile 引数を付けて aws コマンドを実行する
aws_cmd() {
  if [ -n "${AWS_PROFILE}" ]; then
    aws --profile "${AWS_PROFILE}" "$@"
  else
    aws "$@"
  fi
}

if [ -n "${AWS_PROFILE}" ]; then
  PROFILE_MSG="🔧 使用するAWSプロファイル: ${AWS_PROFILE}"
else
  PROFILE_MSG="🔧 AWSプロファイルが指定されていないため、デフォルトのプロファイルを使用します。"
fi

set -e

echo "==================== Terraform Backend セットアップ ===================="
echo "${PROFILE_MSG}"
echo "🚀 アプリケーション名: ${TF_VAR_project_name}"
echo "🌐 リージョン: ${AWS_REGION}"
echo "📦 S3バケット名: ${BUCKET_NAME}"
echo "🔒 DynamoDBテーブル名: ${DYNAMODB_TABLE_NAME}"
echo "========================================================================"

# AWSプロファイルの確認
if ! aws_cmd sts get-caller-identity >/dev/null 2>&1; then
  echo "❌ エラー: AWS認証に失敗しました。AWSプロファイル「${AWS_PROFILE:-<default>}」の設定を確認してください。"
  exit 1
fi

echo "✅ AWSプロファイルの認証に成功しました"

# --- S3バケットの作成・設定 ---
echo ""
echo "📦 S3バケットのセットアップを開始します..."

# バケットの存在チェック
if aws_cmd s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "✅ バケット「${BUCKET_NAME}」は既に存在します。作成をスキップします。"
else
  echo "🚀 S3バケット「${BUCKET_NAME}」をリージョン「${AWS_REGION}」に作成します。"
  
  # us-east-1の場合は LocationConstraint を指定しない
  if [ "${AWS_REGION}" = "us-east-1" ]; then
    aws_cmd s3api create-bucket \
      --bucket "${BUCKET_NAME}" \
      --region "${AWS_REGION}"
  else
    aws_cmd s3api create-bucket \
      --bucket "${BUCKET_NAME}" \
      --region "${AWS_REGION}" \
      --create-bucket-configuration LocationConstraint="${AWS_REGION}"
  fi
  echo "✅ バケット「${BUCKET_NAME}」を作成しました。"
fi

echo "🔄 バケット「${BUCKET_NAME}」のバージョニングを有効化します。"
aws_cmd s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

echo "🔐 バケット「${BUCKET_NAME}」のサーバーサイド暗号化を有効化します。"
aws_cmd s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      },
      "BucketKeyEnabled": true
    }]
  }'

echo "🚫 バケット「${BUCKET_NAME}」のパブリックアクセスをブロックします。"
aws_cmd s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# --- DynamoDBテーブルの作成 ---
echo ""
echo "🔒 DynamoDBテーブルのセットアップを開始します..."

# DynamoDBテーブルの存在チェック
if aws_cmd dynamodb describe-table --table-name "${DYNAMODB_TABLE_NAME}" >/dev/null 2>&1; then
  echo "✅ DynamoDBテーブル「${DYNAMODB_TABLE_NAME}」は既に存在します。作成をスキップします。"
else
  echo "🚀 DynamoDBテーブル「${DYNAMODB_TABLE_NAME}」を作成します。"
  aws_cmd dynamodb create-table \
    --table-name "${DYNAMODB_TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

  echo "⏳ テーブルがアクティブになるまで待機中..."
  aws_cmd dynamodb wait table-exists --table-name "${DYNAMODB_TABLE_NAME}"
  echo "✅ DynamoDBテーブル「${DYNAMODB_TABLE_NAME}」を作成しました。"
fi

# --- backend.hcl ファイルの生成 ---
echo ""
echo "📝 backend.hcl ファイルを生成します..."

BACKEND_CONFIG_PATH="${SCRIPT_DIR}/terraform/backend.hcl"

# terraformディレクトリが存在しない場合は作成
mkdir -p "${SCRIPT_DIR}/terraform"

cat > "${BACKEND_CONFIG_PATH}" << EOF
bucket         = "${BUCKET_NAME}"
region         = "${AWS_REGION}"
dynamodb_table = "${DYNAMODB_TABLE_NAME}"
EOF

echo "✅ backend.hcl ファイルを生成しました: ${BACKEND_CONFIG_PATH}"

# --- 設定確認 ---
echo ""
echo "🔍 設定の確認を行います..."

# S3バケット設定の確認
echo "📦 S3バケット設定:"
echo "  - バケット名: ${BUCKET_NAME}"
echo "  - リージョン: $(aws_cmd s3api get-bucket-location --bucket "${BUCKET_NAME}" --query 'LocationConstraint' --output text 2>/dev/null || echo 'us-east-1')"
echo "  - バージョニング: $(aws_cmd s3api get-bucket-versioning --bucket "${BUCKET_NAME}" --query 'Status' --output text)"
echo "  - 暗号化: $(aws_cmd s3api get-bucket-encryption --bucket "${BUCKET_NAME}" --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null || echo '未設定')"

# DynamoDB設定の確認
echo "🔒 DynamoDBテーブル設定:"
echo "  - テーブル名: ${DYNAMODB_TABLE_NAME}"
echo "  - ステータス: $(aws_cmd dynamodb describe-table --table-name "${DYNAMODB_TABLE_NAME}" --query 'Table.TableStatus' --output text)"

echo ""
echo "✅ Terraform Backend のセットアップが完了しました！"
echo ""
echo "🔧 次のステップ:"
echo "1. backend.tf ファイルが正しく設定されていることを確認"
echo "2. 以下のコマンドでTerraformを初期化:"
echo "   terraform init \\"
echo "     -backend-config=\"bucket=${BUCKET_NAME}\" \\"
echo "     -backend-config=\"region=${AWS_REGION}\" \\"
echo "     -backend-config=\"dynamodb_table=${DYNAMODB_TABLE_NAME}\""
echo ""
echo "🐳 Dockerを使用する場合:"
echo "   docker-compose run --rm terraform"
echo "   # コンテナ内で上記のterraform initコマンドを実行"