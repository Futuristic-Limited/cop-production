import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    // Today - show time only
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  } else if (messageDate == yesterday) {
    // Yesterday - show "Yesterday"
    return "Yesterday";
  } else {
    // Older dates - show date in MM/DD/YYYY format
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }
}

String formatTimeHumanReadable(String rawDate) {
  try {
    final dateTime = DateTime.parse(rawDate);
    return DateFormat('hh:mm a').format(dateTime);
  } catch (e) {
    return rawDate;
  }
}
