# BLE Helper

[English](README.md) · **简体中文**

**面向硬件开发的 Android BLE 调试助手。**

BLE Helper 使用 Flutter 开发，可扫描低功耗蓝牙设备、连接外设、浏览 GATT 服务、读写特征值、订阅通知，并导出本地调试日志。

## 功能

- 设备扫描、名称与 RSSI 展示、排序与筛选
- 设备连接、RSSI 与连接状态跟踪
- GATT 服务、特征值与描述符浏览
- 特征值读取、写入与通知订阅
- 本地日志存储、筛选、保留策略、归档与导出
- 主题、扫描时长、默认数据格式、日志保留与重连设置
- 固件文件解析，以及供平台集成的 DFU 适配器框架

## 平台状态

当前以 Android 为目标平台。平台层采用抽象接口，后续可增加平台实现，无需改变应用、BLoC 或数据层。

**DFU 当前为适配器框架，仍需接入实际升级后端并完成真机验证。**

## 环境要求

- Flutter 3.22 或更新版本
- Dart 3.5 或更新版本
- Android 构建所需的 Android SDK
- 用于硬件验证的支持 BLE 的 Android 真机

## 快速开始

安装依赖：

```sh
flutter pub get
```

运行应用：

```sh
flutter run
```

运行静态分析与测试：

```sh
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

修改数据库结构后，重新生成 Drift 数据库代码：

```sh
dart run build_runner build --delete-conflicting-outputs
```

## 代码结构

- `lib/bloc`：应用状态机
- `lib/core`：路由、依赖注入、常量、主题和工具函数
- `lib/data`：Drift 数据库、仓储与领域模型
- `lib/screens`：功能页面及页面专用组件
- `lib/services`：BLE、DFU、日志与平台服务抽象
- `test`：单元测试与组件测试
- `docs`：架构和时序图

## 真机验证

BLE 行为受 Android 权限、硬件、固件与周围无线环境影响。修改扫描、连接或 GATT 行为后，需要在支持 BLE 的真机上验证。DFU 在接入实际升级后端前不应作为可用升级功能使用。

## 许可证

采用 MIT 许可证，详见 [LICENSE](LICENSE)。
