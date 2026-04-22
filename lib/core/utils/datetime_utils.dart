import 'dart:developer' as dev;

class DateTimeUtils {
  /// Parses a value from API and automatically adds 7 hours for Vietnam timezone (UTC+7).
  static DateTime parseApiDate(dynamic value) {
    if (value == null) {
      return DateTime.now().add(const Duration(hours: 7));
    }

    try {
      DateTime dt;
      if (value is DateTime) {
        dt = value;
      } else {
        final str = value.toString().trim();
        // Handle DD/MM/YYYY format if present
        if (str.contains('/') && str.split('/').length >= 3) {
          final parts = str.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final yearPart = parts[2].split(' ')[0];
          final year = int.parse(yearPart);
          dt = DateTime(year, month, day);
        } else {
          dt = DateTime.parse(str);
        }
      }
      
      // Automatic +7 hours shift as per global rule
      return dt.add(const Duration(hours: 7));
    } catch (e) {
      dev.log('DateTimeUtils: Error parsing date "$value": $e');
      return DateTime.now().add(const Duration(hours: 7));
    }
  }

  /// Optional: If we want to safely parse without the +7 shift for specific cases
  /// Automatically converts to local time if the string ends with 'Z'
  static DateTime parseRaw(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      if (value is DateTime) return value.toLocal();
      final str = value.toString().trim();
      
      // Handle ISO strings with 'Z' or offsets
      DateTime dt = DateTime.parse(str);
      
      // If it's UTC (e.g. ends with Z), convert to local
      if (str.endsWith('Z') || str.contains('+') || (str.contains('-') && str.contains('T') && str.lastIndexOf('-') > str.lastIndexOf('T'))) {
        return dt.toLocal();
      }
      
      return dt;
    } catch (_) {
      return DateTime.now();
    }
  }
}
