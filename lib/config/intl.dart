class SimpleDateFormatter {
  static final List<String> _monthNames = [
    '', // 1-based index: months start at 1, so index 0 is empty
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  /// Format a DateTime as 'Month Year', e.g. 'May 2025'
  static String formatMonthYear(DateTime date) {
    final monthName = _monthNames[date.month];
    final year = date.year;
    return '$monthName $year';
  }
}
