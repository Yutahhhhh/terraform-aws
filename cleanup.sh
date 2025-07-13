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

# 必要な環境変数が設定されているかチェック
: "${TF_VAR_project_name?エラー: 環境変数 TF_VAR_project_name が設定されていません。.envファイルで定義してください。}"
: "${AWS_REGION?エラー: 環境変数 AWS_REGION が設定されていません。.envファイルで定義してください。}"

# リソース名を自動生成
BUCKET_NAME="${TF_VAR_project_name}-terraform-state"
DYNAMODB_TABLE_NAME="${TF_VAR_project_name}-terraform-state-locks"

# AWSコマンドのラッパー関数を定義
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

echo "=================== Terraform Backend クリーンアップ ==================="
echo "${PROFILE_MSG}"
echo "🚀 アプリケーション名: ${TF_VAR_project_name}"
echo "🌐 リージョン: ${AWS_REGION}"
echo "📦 削除対象S3バケット: ${BUCKET_NAME}"
echo "🔒 削除対象DynamoDBテーブル: ${DYNAMODB_TABLE_NAME}"
echo "========================================================================"

# AWSプロファイルの確認
if ! aws_cmd sts get-caller-identity >/dev/null 2>&1; then
  echo "❌ エラー: AWS認証に失敗しました。AWSプロファイル「${AWS_PROFILE:-<default>}」の設定を確認してください。"
  exit 1
fi

echo "✅ AWSプロファイルの認証に成功しました"

# 現在の設定確認
echo ""
echo "🔍 現在の設定を確認しています..."

# S3バケットの存在確認
S3_EXISTS=false
if aws_cmd s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  S3_EXISTS=true
  echo "📦 S3バケット「${BUCKET_NAME}」が存在します"
  
  # バケット内のオブジェクト数確認
  OBJECT_COUNT=$(aws_cmd s3 ls s3://"${BUCKET_NAME}" --recursive --summarize 2>/dev/null | grep "Total Objects:" | awk '{print $3}' || echo "0")
  echo "  - オブジェクト数: ${OBJECT_COUNT}"
  
  # バケットサイズ確認
  BUCKET_SIZE=$(aws_cmd s3 ls s3://"${BUCKET_NAME}" --recursive --summarize --human-readable 2>/dev/null | grep "Total Size:" | awk '{print $3 " " $4}' || echo "不明")
  echo "  - 合計サイズ: ${BUCKET_SIZE}"
else
  echo "📦 S3バケット「${BUCKET_NAME}」は存在しません"
fi

# DynamoDBテーブルの存在確認
DYNAMODB_EXISTS=false
if aws_cmd dynamodb describe-table --table-name "${DYNAMODB_TABLE_NAME}" >/dev/null 2>&1; then
  DYNAMODB_EXISTS=true
  echo "🔒 DynamoDBテーブル「${DYNAMODB_TABLE_NAME}」が存在します"
  
  # テーブルのアイテム数確認
  ITEM_COUNT=$(aws_cmd dynamodb scan --table-name "${DYNAMODB_TABLE_NAME}" --select COUNT --query 'Count' --output text 2>/dev/null || echo "不明")
  echo "  - アイテム数: ${ITEM_COUNT}"
else
  echo "🔒 DynamoDBテーブル「${DYNAMODB_TABLE_NAME}」は存在しません"
fi

# 削除するリソースがない場合
if [ "$S3_EXISTS" = false ] && [ "$DYNAMODB_EXISTS" = false ]; then
  echo ""
  echo "ℹ️  削除対象のリソースが存在しません。処理を終了します。"
  exit 0
fi

# 削除確認
echo ""
echo "⚠️  注意: この操作は元に戻せません！"
echo ""
echo "以下のリソースが削除されます:"
if [ "$S3_EXISTS" = true ]; then
  echo "  - S3バケット: ${BUCKET_NAME} (全てのオブジェクトとバージョンを含む)"
fi
if [ "$DYNAMODB_EXISTS" = true ]; then
  echo "  - DynamoDBテーブル: ${DYNAMODB_TABLE_NAME} (全てのデータを含む)"
fi
echo ""
printf "本当に削除しますか？ (yes/no): "
read -r CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
  echo "❌ 削除をキャンセルしました。"
  exit 0
fi

set -e

# --- S3バケットの削除 ---
if [ "$S3_EXISTS" = true ]; then
  echo ""
  echo "🗑️  S3バケットの削除を開始します..."
  
  echo "📋 バケット内の全オブジェクトとバージョンをリストアップしています..."
  
  # すべてのオブジェクトバージョンを削除
  echo "🔄 全オブジェクトバージョンを削除中..."
  aws_cmd s3api list-object-versions --bucket "${BUCKET_NAME}" --query 'Versions[].[Key,VersionId]' --output text | while read -r key version_id; do
    if [ -n "$key" ] && [ -n "$version_id" ]; then
      echo "  削除中: $key (Version: $version_id)"
      aws_cmd s3api delete-object --bucket "${BUCKET_NAME}" --key "$key" --version-id "$version_id" >/dev/null
    fi
  done
  
  # すべてのデリートマーカーを削除
  echo "🔄 全デリートマーカーを削除中..."
  aws_cmd s3api list-object-versions --bucket "${BUCKET_NAME}" --query 'DeleteMarkers[].[Key,VersionId]' --output text | while read -r key version_id; do
    if [ -n "$key" ] && [ -n "$version_id" ]; then
      echo "  削除中: $key (DeleteMarker: $version_id)"
      aws_cmd s3api delete-object --bucket "${BUCKET_NAME}" --key "$key" --version-id "$version_id" >/dev/null
    fi
  done
  
  # バケット自体を削除
  echo "🗑️  S3バケット自体を削除中..."
  aws_cmd s3api delete-bucket --bucket "${BUCKET_NAME}"
  echo "✅ S3バケット「${BUCKET_NAME}」を削除しました"
fi

# --- DynamoDBテーブルの削除 ---
if [ "$DYNAMODB_EXISTS" = true ]; then
  echo ""
  echo "🗑️  DynamoDBテーブルの削除を開始します..."
  
  aws_cmd dynamodb delete-table --table-name "${DYNAMODB_TABLE_NAME}"
  
  echo "⏳ テーブルが削除されるまで待機中..."
  
  # テーブル削除の完了を待機（最大5分）
  WAIT_COUNT=0
  MAX_WAIT=30  # 30回 × 10秒 = 5分
  
  while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if ! aws_cmd dynamodb describe-table --table-name "${DYNAMODB_TABLE_NAME}" >/dev/null 2>&1; then
      echo "✅ DynamoDBテーブル「${DYNAMODB_TABLE_NAME}」を削除しました"
      break
    fi
    sleep 10
    WAIT_COUNT=$((WAIT_COUNT + 1))
    echo "  待機中... ($((WAIT_COUNT * 10))秒経過)"
  done
  
  if [ $WAIT_COUNT -eq $MAX_WAIT ]; then
    echo "⚠️  テーブル削除の完了確認がタイムアウトしました。AWS コンソールで確認してください。"
  fi
fi

echo ""
echo "✅ Terraform Backend のクリーンアップが完了しました！"
echo ""
echo "🔧 削除されたリソース:"
if [ "$S3_EXISTS" = true ]; then
  echo "  - S3バケット: ${BUCKET_NAME}"
fi
if [ "$DYNAMODB_EXISTS" = true ]; then
  echo "  - DynamoDBテーブル: ${DYNAMODB_TABLE_NAME}"
fi
echo ""
echo "💡 注意事項:"
echo "  - Terraformのstate ファイルは削除されました"
echo "  - 今後terraform操作を行う場合は、setup.sh を再実行してください"
echo "  - ローカルの .terraform ディレクトリも削除することを推奨します:"
echo "    rm -rf .terraform/ .terraform.lock.hcl"