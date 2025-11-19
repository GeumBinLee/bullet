/// Utility class for formatting entry-related data
class EntryFormatter {
  /// Formats a date as YYYY.MM.DD
  static String formattedDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// Formats a date and time as YYYY.MM.DD HH:MM
  static String formattedDateTime(DateTime dateTime) {
    return '${formattedDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

