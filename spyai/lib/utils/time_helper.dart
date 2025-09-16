class TimeHelper {
  /// Formats DateTime to 12-hour format with AM/PM
  static String formatTime12Hour(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return "${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period";
  }

  /// Formats DateTime to 24-hour format
  static String formatTime24Hour(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  /// Formats DateTime to recording timestamp format (YYYY-MM-DD HH:MM:SS)
  static String formatRecordingTimestamp(DateTime timestamp) {
    return "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} "
           "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";
  }

  /// Formats duration in seconds to readable format (HH:MM:SS)
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
    }
  }

  /// Gets current timestamp in recording format
  static String getCurrentRecordingTimestamp() {
    return formatRecordingTimestamp(DateTime.now());
  }
}