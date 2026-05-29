#!/bin/bash
# 打包 TextPocket 为 DMG
set -e

cd "$(dirname "$0")/.."
APP_NAME="TextPocket"
DMG_NAME="${APP_NAME}.dmg"
VOLUME_NAME="TextPocket"
DMG_PATH="build/${DMG_NAME}"
APP_PATH="build/${APP_NAME}.app"

# 先打包 .app
echo "📦 打包 .app..."
scripts/package.sh

# 清理旧 DMG
rm -f "${DMG_PATH}"

# 创建临时目录
TMP_DIR=$(mktemp -d)
cp -R "${APP_PATH}" "${TMP_DIR}/"
ln -s /Applications "${TMP_DIR}/Applications"

# 创建 DMG
echo "💿 创建 DMG..."
hdiutil create \
    -volname "${VOLUME_NAME}" \
    -srcfolder "${TMP_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

# 清理
rm -rf "${TMP_DIR}"

echo "✅ DMG 已生成: ${DMG_PATH}"
