#!/bin/bash

# CloudWatchロググループ削除スクリプト（既にterraform destroy済みの環境用）
# 使用方法: ./cleanup-logs.sh [environment]
# 例: ./cleanup-logs.sh dev

set -e

# 引数の確認
if [ $# -ne 1 ]; then
    echo "使用方法: $0 <environment>"
    echo "利用可能な環境: dev, stg, prod"
    exit 1
fi

ENVIRONMENT="$1"

# 環境の検証
if [[ ! "$ENVIRONMENT" =~ ^(dev|stg|prod)$ ]]; then
    echo "エラー: 無効な環境です。dev, stg, prod のいずれかを指定してください。"
    exit 1
fi

# .envファイルの読み込み
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
if [ -f "${SCRIPT_DIR}/.env" ]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
    echo "✅ .envファイルを読み込みました"
fi

# 必要な環境変数の確認
: "${TF_VAR_project_name?エラー: 環境変数 TF_VAR_project_name が設定されていません。}"

PROJECT_NAME="${TF_VAR_project_name}"

# AWSコマンドのラッパー関数
aws_cmd() {
    if [ -n "${AWS_PROFILE}" ]; then
        aws --profile "${AWS_PROFILE}" "$@"
    else
        aws "$@"
    fi
}

echo "🗑️  ${ENVIRONMENT}環境の残存CloudWatchロググループを削除します..."
echo "プロジェクト: ${PROJECT_NAME}"
echo "環境: ${ENVIRONMENT}"
if [ -n "${AWS_PROFILE}" ]; then
    echo "AWSプロファイル: ${AWS_PROFILE}"
fi
echo ""

# 1. Container Insightsロググループ削除
echo "🔍 Container Insightsロググループを確認中..."
LOG_GROUP="/aws/ecs/containerinsights/${PROJECT_NAME}-${ENVIRONMENT}-cluster/performance"
if aws_cmd logs describe-log-groups --log-group-name-prefix "${LOG_GROUP}" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "${LOG_GROUP}"; then
    echo "🗑️  削除中: ${LOG_GROUP}"
    aws_cmd logs delete-log-group --log-group-name "${LOG_GROUP}"
    echo "✅ Container Insightsロググループを削除しました"
else
    echo "📭 Container Insightsロググループが見つかりません"
fi

# 2. RDS PostgreSQLロググループ削除
echo ""
echo "🔍 RDS PostgreSQLロググループを確認中..."
LOG_GROUP="/aws/rds/instance/${PROJECT_NAME}-${ENVIRONMENT}-db/postgresql"
if aws_cmd logs describe-log-groups --log-group-name-prefix "${LOG_GROUP}" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "${LOG_GROUP}"; then
    echo "🗑️  削除中: ${LOG_GROUP}"
    aws_cmd logs delete-log-group --log-group-name "${LOG_GROUP}"
    echo "✅ RDS PostgreSQLロググループを削除しました"
else
    echo "📭 RDS PostgreSQLロググループが見つかりません"
fi

# 3. ECSアプリケーションロググループ削除
echo ""
echo "🔍 ECSアプリケーションロググループを確認中..."
LOG_GROUP="/ecs/${PROJECT_NAME}-${ENVIRONMENT}"
if aws_cmd logs describe-log-groups --log-group-name-prefix "${LOG_GROUP}" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "${LOG_GROUP}"; then
    echo "🗑️  削除中: ${LOG_GROUP}"
    aws_cmd logs delete-log-group --log-group-name "${LOG_GROUP}"
    echo "✅ ECSアプリケーションロググループを削除しました"
else
    echo "📭 ECSアプリケーションロググループが見つかりません"
fi

# 4. VPCフローログ削除（タイムスタンプ付きのものを検索・削除）
echo ""
echo "🔍 VPCフローログを検索中..."
VPC_LOG_PREFIX="/aws/vpc/${PROJECT_NAME}-${ENVIRONMENT}"
VPC_LOGS=$(aws_cmd logs describe-log-groups --log-group-name-prefix "${VPC_LOG_PREFIX}" --query 'logGroups[].logGroupName' --output text 2>/dev/null || echo "")

if [ -n "$VPC_LOGS" ] && [ "$VPC_LOGS" != "None" ]; then
    echo "$VPC_LOGS" | tr '\t' '\n' | while read -r log_group; do
        if [[ -n "$log_group" ]]; then
            echo "🗑️  VPCフローログを削除中: $log_group"
            aws_cmd logs delete-log-group --log-group-name "$log_group" && echo "✅ 削除完了: $log_group" || echo "⚠️  削除に失敗: $log_group"
        fi
    done
else
    echo "📭 VPCフローログが見つかりません"
fi

echo ""
echo "✅ ${ENVIRONMENT}環境のCloudWatchロググループ削除処理が完了しました"
echo ""
echo "💡 残っているロググループを確認するには:"
echo "aws logs describe-log-groups --query 'logGroups[?contains(logGroupName, \`${PROJECT_NAME}\`)].logGroupName' --output table"
