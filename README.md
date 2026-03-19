# TL-EPUB-Reader

跨平台 EPUB 阅读器，支持章节文本复制功能。

## 功能特性

- 📚 **书库管理**：导入、管理多个 EPUB 文件
- 📖 **阅读器**：左侧目录 + 右侧内容的双栏布局
- 📋 **章节复制**：一键复制当前章节全部文本
- 🎨 **Material Design**：现代化 UI 设计

## 技术栈

- **框架**：Flutter 3.x
- **语言**：Dart
- **平台**：Linux, Web, macOS, Windows, Android, iOS

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── book.dart
│   ├── book_metadata.dart
│   ├── chapter_content.dart
│   └── toc_entry.dart
├── screens/                  # 页面
│   ├── library_screen.dart   # 书库页面
│   └── reader_screen.dart    # 阅读器页面
├── services/                 # 服务
│   ├── epub_parser_service.dart
│   └── library_service.dart
└── theme/
    └── app_theme.dart
```

## 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### 安装依赖

```bash
flutter pub get
```

### 运行

```bash
# Linux
flutter run -d linux

# Web
flutter run -d chrome

# 其他平台
flutter run -d <device>
```

### 构建

```bash
# Linux
flutter build linux --release

# Web
flutter build web --release

# Android APK
flutter build apk --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release

# iOS
flutter build ios --release
```

## 已构建版本

| 平台 | 状态 | 文件 |
|------|------|------|
| Linux x64 | ✅ | `release/epub-reader-linux-x64.tar.gz` |
| Web | ✅ | `release/epub-reader-web.tar.gz` |
| macOS | ⏳ | 需要 Mac 设备 |
| Windows | ⏳ | 需要 Windows 设备 |
| Android | ⏳ | 需要 Android SDK |
| iOS | ⏳ | 需要 Mac + Xcode |

## 核心功能说明

### EPUB 解析

支持标准 EPUB 2.x/3.x 格式，自动解析：
- 书籍元数据（标题、作者、封面）
- 目录结构（TOC）
- 章节内容（XHTML）

### 章节复制

阅读器页面底部提供「复制本章全部文本」按钮，一键提取当前章节的纯文本内容到剪贴板。

## 开发背景

基于 [karpathy/reader3](https://github.com/karpathy/reader3) 的设计理念开发。

## 许可证

MIT License
