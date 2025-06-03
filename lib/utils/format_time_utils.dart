import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
  final now = DateTime.now();
  if (now.difference(dateTime).inDays == 0) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  } else {
    return "${dateTime.month}/${dateTime.day}";
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
