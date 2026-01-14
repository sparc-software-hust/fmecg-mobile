import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Platform-aware file saver that abstracts storage directory paths.
/// 
/// - Android: Uses external storage directory (/storage/self/primary/fmecg)
/// - iOS: Uses application documents directory
class PlatformFileSaver {
  static const String _appFolderName = 'fmecg';

  /// Get the appropriate storage directory based on the platform.
  /// 
  /// Returns the full path to the app's storage directory.
  static Future<String> getStorageDirectory() async {
    if (Platform.isAndroid) {
      return await _getAndroidStorageDirectory();
    } else if (Platform.isIOS) {
      return await _getIOSStorageDirectory();
    } else {
      // Fallback for other platforms (desktop, web, etc.)
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$_appFolderName';
    }
  }

  /// Get Android external storage directory.
  static Future<String> _getAndroidStorageDirectory() async {
    // Primary external storage path for Android
    const String primaryPath = '/storage/self/primary';
    return '$primaryPath/$_appFolderName';
  }

  /// Get iOS application documents directory.
  static Future<String> _getIOSStorageDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_appFolderName';
  }

  /// Create a file with the given filename in the storage directory.
  /// 
  /// [filename] - Name of the file to create (e.g., 'data.csv')
  /// [subfolder] - Optional subfolder within the storage directory
  /// [createIfNotExists] - Whether to create the file if it doesn't exist
  static Future<File> createFile({
    required String filename,
    String? subfolder,
    bool createIfNotExists = true,
  }) async {
    final baseDirectory = await getStorageDirectory();
    final String directoryPath = subfolder != null 
        ? '$baseDirectory/$subfolder' 
        : baseDirectory;

    // Ensure directory exists
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('$directoryPath/$filename');
    
    if (createIfNotExists && !await file.exists()) {
      await file.create();
    }

    return file;
  }

  /// Delete a file and recreate it (for fresh recordings).
  /// 
  /// [file] - The file to reset
  static Future<File> resetFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
    await file.create(recursive: true);
    return file;
  }

  /// Check if the storage directory exists and is accessible.
  static Future<bool> isStorageAccessible() async {
    try {
      final directoryPath = await getStorageDirectory();
      final directory = Directory(directoryPath);
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      return true;
    } catch (e) {
      print('[PlatformFileSaver] Storage not accessible: $e');
      return false;
    }
  }

  /// Get all files in the storage directory with a specific extension.
  /// 
  /// [extension] - File extension to filter (e.g., '.csv')
  /// [subfolder] - Optional subfolder to search in
  static Future<List<File>> getFilesWithExtension({
    required String extension,
    String? subfolder,
  }) async {
    final baseDirectory = await getStorageDirectory();
    final String directoryPath = subfolder != null 
        ? '$baseDirectory/$subfolder' 
        : baseDirectory;

    final directory = Directory(directoryPath);
    
    if (!await directory.exists()) {
      return [];
    }

    final List<File> files = [];
    await for (final entity in directory.list()) {
      if (entity is File && entity.path.endsWith(extension)) {
        files.add(entity);
      }
    }

    return files;
  }
}
