# TextPocket

轻量级 Mac 菜单栏文本片段管理工具。一键存储、快速搜索、自动粘贴常用文本。

## 功能特性

- **菜单栏常驻** — 不占 Dock 位置，随时可用
- **全局快捷键** — `Cmd+Shift+V` 一键呼出浮窗
- **自动记录剪贴板** — 后台监听复制操作，自动保存常用文本
- **智能去重** — 相同内容不重复记录，仅更新使用频率
- **实时搜索** — 按标题或内容快速过滤
- **一键粘贴** — 选择记录后自动复制并粘贴到光标位置
- **本地存储** — 使用 SwiftData 持久化，数据完全在本地
- **右键删除** — 上下文菜单管理记录

## 快速开始

### 环境要求

- macOS 14.0+
- Xcode Command Line Tools

### 构建并运行

```bash
# 克隆项目
git clone <repo-url> TextPocket
cd TextPocket

# 一键打包并启动
scripts/run.sh
```

### 脚本说明

| 脚本 | 用途 |
|------|------|
| `scripts/build.sh` | 仅编译项目 |
| `scripts/package.sh` | 编译 + 打包为 `.app` |
| `scripts/run.sh` | 编译 + 打包 + 启动 |

打包产物位于 `build/TextPocket.app`。

## 使用方法

### 首次启动

1. 启动应用后，菜单栏出现 📋 图标
2. 系统会弹出辅助功能权限请求，点击「允许」
3. 若未弹出，手动前往：**系统设置 → 隐私与安全性 → 辅助功能**，添加 TextPocket

### 日常使用

1. **呼出浮窗** — 点击菜单栏图标，或按 `Cmd+Shift+V`
2. **自动记录** — 在任意应用中复制文本（`Cmd+C`），TextPocket 自动保存到列表
3. **手动添加** — 点击底部「+ 添加新记录」，输入标题（可选）和内容（必填），点击保存
4. **搜索记录** — 在顶部搜索框输入关键词，列表实时过滤
5. **粘贴记录** — 点击任意记录，内容自动复制并粘贴到当前光标位置
6. **删除记录** — 右键点击记录，选择「删除」

> **自动记录规则：** 仅记录 2 字符以上的纯文本，相同内容不会重复记录（仅更新使用频率）。应用自身触发的粘贴操作不会被记录。

## 技术栈

| 组件 | 技术 |
|------|------|
| 语言 | Swift 5.9+ |
| UI | SwiftUI |
| 数据持久化 | SwiftData |
| 全局快捷键 | [HotKey](https://github.com/soffes/HotKey) |
| 包管理 | Swift Package Manager |

## 项目结构

```
TextPocket/
├── Package.swift                        # SPM 依赖配置
├── scripts/                             # 构建与运行脚本
│   ├── build.sh
│   ├── package.sh
│   └── run.sh
├── TextPocket/
│   ├── TextPocketApp.swift              # 应用入口 + AppDelegate
│   ├── Info.plist                       # 应用配置（LSUIElement）
│   ├── TextPocket.entitlements          # 权限配置
│   ├── Models/
│   │   └── ClipboardItem.swift          # SwiftData 数据模型
│   ├── ViewModels/
│   │   └── ClipboardViewModel.swift     # 业务逻辑
│   ├── Views/
│   │   ├── PopoverView.swift            # 浮窗主视图
│   │   ├── SearchBar.swift              # 搜索框
│   │   ├── RecordListView.swift         # 记录列表
│   │   ├── RecordRowView.swift          # 单条记录
│   │   └── AddRecordView.swift          # 添加记录表单
│   ├── Services/
│   │   ├── AccessibilityService.swift   # 辅助功能权限管理
│   │   ├── ClipboardMonitor.swift       # 剪贴板自动监听
│   │   ├── PasteService.swift           # 剪贴板操作 + 模拟粘贴
│   │   └── HotkeyService.swift          # 全局快捷键注册
│   └── Resources/
└── docs/                                # 设计文档
```

## 权限说明

| 权限 | 用途 | 必需 |
|------|------|------|
| 辅助功能 (Accessibility) | 模拟 Cmd+V 粘贴到其他应用 | 是 |

应用不联网，不收集任何数据，所有记录存储在本地 SwiftData 数据库中。
