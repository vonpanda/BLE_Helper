# Contributing

Thanks for your interest in improving BLE Helper.

## Development Workflow

1. Fork the repository and create a focused branch.
2. Install dependencies with `flutter pub get`.
3. Make the smallest cohesive change that solves the issue.
4. Run `flutter analyze` and `flutter test`.
5. Open a pull request with a clear description, test notes, and any hardware
   validation details for BLE changes.

## Code Style

- Follow the lint rules in `analysis_options.yaml`.
- Keep platform-specific behavior behind the platform or service abstractions.
- Prefer tests around models, BLoCs, repositories, and parsing logic.
- Document hardware-specific assumptions in the pull request.

## BLE Validation

For scan, connection, GATT, notification, MTU, or DFU work, include the tested
Android version, device model, peripheral model, and firmware version when
available.
