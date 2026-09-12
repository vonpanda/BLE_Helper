# BLE Helper

**面向硬件工程师的 Android BLE 调试助手**  
*An Android BLE debugging companion for hardware development.*

扫描设备、检查 GATT 服务、读写特征值、订阅通知，并保留可导出的调试日志。

`Flutter` · `Dart` · `BLE GATT` · `BLoC` · `Drift`

[快速开始](#getting-started) · [代码结构](#repository-layout) · [平台状态](#platform-status) · [测试代码](test)

## 功能导览

| 调试环节 | 功能 |
| --- | --- |
| 发现设备 | 扫描、名称与 RSSI 展示、筛选与排序 |
| 建立连接 | 连接状态与 RSSI 跟踪 |
| 检查协议 | 服务、特征值、描述符浏览 |
| 收发数据 | 特征值读写、通知订阅 |
| 保留现场 | 本地日志、筛选、归档与导出 |

**当前边界：** 目标平台为 Android；DFU 为适配器框架，仍需接入实际升级后端并完成真机验证。

## Overview

BLE Helper is a Flutter application for hardware engineers who need a mobile
BLE debugging assistant during embedded device development. It can scan
Bluetooth Low Energy devices, connect to peripherals, inspect GATT services,
read and write characteristics, monitor notifications, and export local
activity logs.

## Features

- BLE device discovery with name, RSSI, and sorting/filtering support
- Device connection workflow with RSSI and connection state tracking
- GATT service, characteristic, and descriptor browsing
- Characteristic read, write, and notification operations
- Local activity log storage with filtering, retention, archive, and export tools
- Theme, scan duration, default data format, log retention, and reconnect settings
- Firmware file parsing and a DFU adapter scaffold for platform integration

## Platform Status

The current implementation targets Flutter on Android. The platform layer is
kept abstract so additional platform implementations can be added without
changing the app, BLoC, or data layers.

## Requirements

- Flutter 3.22 or newer
- Dart 3.5 or newer
- Android SDK for Android builds
- A BLE-capable Android device for hardware validation

## Getting Started

Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run
```

Run static analysis and tests:

```sh
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Regenerate Drift database code after database schema changes:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Repository Layout

- `lib/bloc`: application state machines
- `lib/core`: routing, dependency injection, constants, theme, and utilities
- `lib/data`: Drift database, repositories, and domain models
- `lib/screens`: feature screens and screen-specific widgets
- `lib/services`: BLE, DFU, log, and platform service abstractions
- `test`: unit and widget tests
- `docs`: architecture and sequence diagrams

## Notes

BLE behavior depends on Android permissions, hardware, firmware, and nearby
radio conditions. Always validate changes on a physical BLE-capable device when
modifying scan, connection, or GATT behavior. DFU support is currently an
adapter scaffold and requires wiring a production DFU backend before use.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
