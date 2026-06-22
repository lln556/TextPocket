# TextPocket

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0+-blue?logo=apple" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">
</p>

轻量级 Mac 菜单栏文本片段管理工具。一键存储、快速搜索、自动粘贴常用文本。

![demo](https://github.com/lln556/TextPocket/assets/demo.gif)

## ✨ 功能特性

- **菜单栏常驻** — 不占 Dock 位置，随时可用
- **全局快捷键** — `Cmd+Shift+V` 一键呼出浮窗
- **自动记录剪贴板** — 复制的文本自动保存，无需手动操作
- **智能去重** — 相同内容不重复记录，仅更新时间
- **最近 / 常用双 Tab** — 最近剪贴板 vs 手动常用文本，分区管理
- **模糊搜索 + 高亮** — 输入关键字即可模糊匹配，匹配字符高亮显示
- **一键粘贴** — 选择记录后自动粘贴到当前光标位置
- **右键菜单** — 编辑内容、添加到常用、删除记录
- **纯本地存储** — 使用 SwiftData 持久化，数据不离开你的电脑

## 📦 安装

### 方式一：下载 DMG（推荐）

前往 [Releases](https://github.com/lln556/TextPocket/releases) 页面下载最新版本的 `TextPocket.dmg`，双击打开后将 TextPocket 拖入 Applications 文件夹。

### 方式二：从源码构建

```bash
git clone https://github.com/lln556/TextPocket.git
cd TextPocket
scripts/run.sh
```

## 🚀 使用方法

### 首次启动

1. 启动应用后，菜单栏出现 📋 图标
2. 系统会弹出辅助功能权限请求，点击「允许」
3. 若未弹出，手动前往：**系统设置 → 隐私与安全性 → 辅助功能**，添加 TextPocket

### 日常操作

| 操作 | 方法 |
|------|------|
| 呼出浮窗 | 点击菜单栏图标 或 按 `Cmd+Shift+V` |
| 自动记录 | 在任意应用中 `Cmd+C` 复制文本，自动保存 |
| 手动添加 | 点击底部「+ 添加新记录」 |
| 搜索 | 在搜索框输入关键字（支持模糊匹配） |
| 粘贴 | 点击任意记录，自动粘贴到光标位置 |
| 编辑 | 右键记录 → 编辑 |
| 添加到常用 | 右键最近记录 → 添加到常用 |
| 删除 | 右键记录 → 删除 |

> **自动记录规则：** 仅记录 2 字符以上的纯文本，相同内容不重复记录。应用自身触发的粘贴不会被记录。

## 🏗 技术栈

| 组件 | 技术 |
|------|------|
| 语言 | Swift 5.9+ |
| UI 框架 | SwiftUI |
| 数据持久化 | SwiftData |
| 全局快捷键 | [HotKey](https://github.com/soffes/HotKey) |
| 包管理 | Swift Package Manager |

## 📁 项目结构

```
TextPocket/
├── Package.swift                        # SPM 依赖配置
├── scripts/                             # 构建与运行脚本
│   ├── build.sh                         # 编译
│   ├── package.sh                       # 打包 .app
│   ├── dmg.sh                           # 打包 DMG
│   └── run.sh                           # 编译 + 打包 + 启动
├── TextPocket/
│   ├── TextPocketApp.swift              # 应用入口
│   ├── Info.plist                       # 应用配置
│   ├── Models/
│   │   └── ClipboardItem.swift          # 数据模型
│   ├── ViewModels/
│   │   └── ClipboardViewModel.swift     # 业务逻辑
│   ├── Views/
│   │   ├── PopoverView.swift            # 浮窗主视图
│   │   ├── SearchBar.swift              # 搜索框
│   │   ├── RecordListView.swift         # 记录列表
│   │   ├── RecordRowView.swift          # 单条记录
│   │   └── AddRecordView.swift          # 添加/编辑记录
│   └── Services/
│       ├── AccessibilityService.swift   # 辅助功能权限
│       ├── ClipboardMonitor.swift       # 剪贴板监听
│       ├── PasteService.swift           # 粘贴服务
│       └── HotkeyService.swift          # 全局快捷键
└── docs/                                # 设计文档
```

## 🔒 权限说明

| 权限 | 用途 | 必需 |
|------|------|------|
| 辅助功能 (Accessibility) | 模拟 Cmd+V 粘贴到其他应用 | ✅ |

应用不联网，不收集任何数据，所有记录存储在本地 SwiftData 数据库中。

## 📄 License

MIT License. 详见 [LICENSE](LICENSE)。
