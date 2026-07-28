import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// File I/O and path utility functions for log export and archive.
class FileUtils {
  FileUtils._();

  /// Get the app's documents directory path (platform-aware).
  static Future<String> getAppDocumentsPath() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Get the app's cache directory path.
  static Future<String> getAppCachePath() async {
    final Directory dir = await getTemporaryDirectory();
    return dir.path;
  }

  /// Ensure a directory exists, creating it if necessary.
  static Future<Directory> ensureDirectory(String path) async {
    final Directory dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Write content to a file, creating parent directories as needed.
  static Future<File> writeFile(String filePath, String content) async {
    final File file = File(filePath);
    await ensureDirectory(p.dirname(filePath));
    return file.writeAsString(content);
  }

  /// Read a file as string. Returns null if the file does not exist.
  static Future<String?> readFile(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  /// Read a file as bytes. Returns null if the file does not exist.
  static Future<List<int>?> readFileBytes(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  /// Get file size in bytes. Returns 0 if the file does not exist.
  static Future<int> getFileSize(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) return 0;
    return file.length();
  }

  /// List all files in a directory matching a given extension.
  static Future<List<FileSystemEntity>> listFiles(
    String directoryPath, {
    String? extension,
  }) async {
    final Directory dir = Directory(directoryPath);
    if (!await dir.exists()) return [];
    final List<FileSystemEntity> entities = dir.listSync();
    if (extension == null) return entities;
    return entities.where((e) => p.extension(e.path) == extension).toList();
  }

  /// Delete a file or directory, returns true on success.
  static Future<bool> deletePath(String path) async {
    final FileSystemEntity entity = Directory(path);
    if (!await entity.exists()) return true;
    try {
      await entity.delete(recursive: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Generate a timestamped filename for exports/archives.
  static String generateTimestampedName(String prefix, String extension) {
    final String now = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    return '${prefix}_$now.$extension';
  }

  /// Generate a unique log archive file path.
  static Future<String> generateArchivePath(
    String baseDir,
    String prefix,
    String extension,
  ) async {
    await ensureDirectory(baseDir);
    final String fileName = generateTimestampedName(prefix, extension);
    return p.join(baseDir, fileName);
  }
}
