import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  /// Gets the directory for storing audio files
  static Future<Directory> getAudioDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDocDir.path}/audio_recordings');
    
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    return audioDir;
  }

  /// Generates a unique filename for audio recordings
  static String generateAudioFileName({String? prefix, String extension = 'wav'}) {
    final timestamp = DateTime.now();
    final formattedTimestamp = "${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}"
        "${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}"
        "${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}";
    
    final prefixStr = prefix != null ? "${prefix}_" : "";
    return "$prefixStr$formattedTimestamp.$extension";
  }

  /// Gets full path for audio file
  static Future<String> getAudioFilePath({String? filename}) async {
    final audioDir = await getAudioDirectory();
    final fileName = filename ?? generateAudioFileName();
    return '${audioDir.path}/$fileName';
  }

  /// Deletes an audio file
  static Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Gets file size in MB
  static Future<double> getFileSizeMB(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes / (1024 * 1024);
      }
      return 0.0;
    } catch (e) {
      print('Error getting file size: $e');
      return 0.0;
    }
  }

  /// Cleans up old audio files (older than specified days)
  static Future<void> cleanupOldFiles({int daysOld = 7}) async {
    try {
      final audioDir = await getAudioDirectory();
      final files = audioDir.listSync();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            print('Deleted old file: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up files: $e');
    }
  }
}