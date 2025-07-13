#!/bin/bash

# このスクリプトはDockerコンテナ内で実行することを想定しています。
# (docker-compose run --rm terraform ./graph.sh)

set -e

# docsディレクトリがなければ作成
if [ ! -d "docs" ]; then
  echo "Creating docs directory..."
  mkdir docs
fi

# 現在の日付を YYYY-MM-DD 形式で取得
DATE=$(date +%Y-%m-%d)
FILENAME="docs/${DATE}_dependency-graph.dot"

# Terraformの作業ディレクトリに移動
cd terraform

echo "Generating dependency graph..."

# 依存関係グラフをファイルに出力
terraform graph > "../${FILENAME}"

echo "Graph data has been generated: ${FILENAME}"