# BLE Helper

**English** · [简体中文](README.zh-CN.md)

**An Android BLE debugging companion for hardware development.**

`Flutter` · `Dart` · `BLE GATT` · `BLoC` · `Drift`

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
