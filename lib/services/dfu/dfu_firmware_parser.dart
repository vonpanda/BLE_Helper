import 'dart:io';

import '../../../data/models/dfu_firmware.dart';

/// Parses firmware files (.zip, .hex, .bin) to extract metadata.
class DfuFirmwareParser {
  DfuFirmwareParser();

  /// Parse a firmware file and return a [DfuFirmware] object with metadata.
  Future<DfuFirmware> parse(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      return DfuFirmware(
        filePath: filePath,
        fileName: _fileName(filePath),
        fileSize: 0,
        chipType: DfuChipType.CUSTOM,
        firmwareVersion: 'Unknown',
        isValid: false,
      );
    }

    final int fileSize = await file.length();
    final String extension = _extension(filePath).toLowerCase();
    final DfuChipType chipType = _guessChipType(filePath, extension);

    return DfuFirmware(
      filePath: filePath,
      fileName: _fileName(filePath),
      fileSize: fileSize,
      chipType: chipType,
      firmwareVersion: 'Unknown',
      isValid: _isValidFirmwareFile(extension),
    );
  }

  /// Check if a file is a valid firmware file based on extension.
  bool _isValidFirmwareFile(String extension) {
    return ['.zip', '.hex', '.bin'].contains(extension);
  }

  /// Guess the chip type from the file name or content.
  DfuChipType _guessChipType(String filePath, String extension) {
    final String fileName = _fileName(filePath).toLowerCase();

    // Nordic DFU files are typically .zip packages
    if (extension == '.zip') {
      if (fileName.contains('nordic') || fileName.contains('nrf')) {
        return DfuChipType.NORDIC;
      }
      // Default ZIP-based DFU to Nordic
      return DfuChipType.NORDIC;
    }

    if (fileName.contains('ti') || fileName.contains('cc2')) {
      return DfuChipType.TI;
    }

    if (fileName.contains('dialog') || fileName.contains('da1')) {
      return DfuChipType.DIALOG;
    }

    if (fileName.contains('nordic') || fileName.contains('nrf')) {
      return DfuChipType.NORDIC;
    }

    // Default: try Nordic for unknowns
    return DfuChipType.NORDIC;
  }

  String _fileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }

  String _extension(String filePath) {
    final int dotIndex = filePath.lastIndexOf('.');
    if (dotIndex < 0) return '';
    return filePath.substring(dotIndex);
  }
}
