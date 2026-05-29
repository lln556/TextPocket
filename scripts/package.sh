#!/bin/bash
# 打包 TextPocket 为 .app bundle
set -e

cd "$(dirname "$0")/.."
APP_NAME="TextPocket"
APP_BUNDLE="build/${APP_NAME}.app"
EXECUTABLE=".build/debug/${APP_NAME}"

# 先构建
echo "🔨 构建项目..."
swift build 2>&1 | tee logs/build.log

# 清理旧的 .app
rm -rf "build"

# 创建 .app 目录结构
echo "📦 打包 ${APP_NAME}.app..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# 复制可执行文件
cp "${EXECUTABLE}" "${APP_BUNDLE}/Contents/MacOS/"

# 复制 Info.plist
cp TextPocket/Info.plist "${APP_BUNDLE}/Contents/"

# 复制图标
if [ -f "TextPocket/Resources/AppIcon.icns" ]; then
    cp TextPocket/Resources/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/"
fi

# 创建 PkgInfo
echo -n "APPL????" > "${APP_BUNDLE}/Contents/PkgInfo"

# ad-hoc 签名
echo "🔏 签名..."
codesign --force --sign - \
    --entitlements TextPocket/TextPocket.entitlements \
    "${APP_BUNDLE}"

echo "✅ 打包完成: ${APP_BUNDLE}"
echo "🚀 运行: open ${APP_BUNDLE}"
