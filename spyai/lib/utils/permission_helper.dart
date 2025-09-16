import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class PermissionHelper {
  static Future<bool> checkAudioPermission() async {
    final AudioRecorder recorder = AudioRecorder();
    return await recorder.hasPermission();
  }

  static Future<bool> requestAudioPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'microphone': await checkAudioPermission(),
      'storage': await checkStoragePermission(),
    };
  }

  static Future<Map<String, bool>> requestAllPermissions() async {
    return {
      'microphone': await requestAudioPermission(),
      'storage': await requestStoragePermission(),
    };
  }
}