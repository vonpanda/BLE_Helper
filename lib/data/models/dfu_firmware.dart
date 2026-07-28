/// Chip types supported for DFU firmware upgrades.
enum DfuChipType {
  NORDIC,
  TI,
  DIALOG,
  CUSTOM,
}

/// Represents a DFU firmware file with metadata.
class DfuFirmware {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DfuChipType chipType;
  final String firmwareVersion;
  final bool isValid;

  const DfuFirmware({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.chipType,
    required this.firmwareVersion,
    this.isValid = true,
  });

  DfuFirmware copyWith({
    String? filePath,
    String? fileName,
    int? fileSize,
    DfuChipType? chipType,
    String? firmwareVersion,
    bool? isValid,
  }) {
    return DfuFirmware(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      chipType: chipType ?? this.chipType,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      isValid: isValid ?? this.isValid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'chipType': chipType.name,
      'firmwareVersion': firmwareVersion,
      'isValid': isValid,
    };
  }

  factory DfuFirmware.fromJson(Map<String, dynamic> json) {
    return DfuFirmware(
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      chipType: DfuChipType.values.firstWhere(
        (e) => e.name == json['chipType'],
        orElse: () => DfuChipType.CUSTOM,
      ),
      firmwareVersion: json['firmwareVersion'] as String? ?? 'Unknown',
      isValid: json['isValid'] as bool? ?? true,
    );
  }

  /// Human-readable file size string.
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() =>
      'DfuFirmware(name: $fileName, chip: $chipType, version: $firmwareVersion)';
}
