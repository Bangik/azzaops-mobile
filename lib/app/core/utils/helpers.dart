class DateHelper {
  static const List<String> _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Format date string (ISO8601 or YYYY-MM-DD) to `DD-Bln-YYYY` (e.g. 11-Agu-2026)
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';

    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = _months[dt.month];
      final year = dt.year.toString();
      return '$day-$month-$year';
    } catch (_) {
      // Fallback if not ISO format (e.g. "2026-08-11")
      final parts = dateStr.split('T').first.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthIdx = int.tryParse(parts[1]) ?? 0;
        final month = (monthIdx >= 1 && monthIdx <= 12) ? _months[monthIdx] : parts[1];
        final day = parts[2].padLeft(2, '0');
        return '$day-$month-$year';
      }
      return dateStr;
    }
  }

  /// Format time string (e.g. "06:23:00" -> "06:23")
  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return timeStr;
  }

  /// Format date and time (e.g. "11-Agu-2026 06:23")
  static String formatDateTime(String? dateStr, {String? timeStr}) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';

    final formattedDate = formatDate(dateStr);
    
    // If explicit time string provided
    if (timeStr != null && timeStr.trim().isNotEmpty) {
      return '$formattedDate ${formatTime(timeStr)}';
    }

    // Try extracting time from ISO string if present
    if (dateStr.contains('T')) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        // Only append time if it is not midnight 00:00 (which often is just a pure date)
        if (hour != '00' || minute != '00') {
          return '$formattedDate $hour:$minute';
        }
      } catch (_) {}
    }

    return formattedDate;
  }
}
