#!/bin/bash
# 构建 TextPocket 项目
set -e

cd "$(dirname "$0")/.."
echo "🔨 构建 TextPocket..."
swift build 2>&1 | tee logs/build.log
echo "✅ 构建完成"
