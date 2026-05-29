#!/bin/bash
# 运行 TextPocket
set -e

cd "$(dirname "$0")/.."

echo "📦 打包并启动 TextPocket..."
scripts/package.sh

echo "🚀 启动 TextPocket..."
open build/TextPocket.app
