/// Pure local-date presentation for offline task deadlines.
/// Epoch values represent UTC instants; labels use the device's local calendar.
String deadlineLabel(int? utcMilliseconds, DateTime now) {
  if (utcMilliseconds == null) return 'Keine Fälligkeit';
  if (utcMilliseconds <= 0) throw FormatException('Invalid deadline');
  final deadline = DateTime.fromMillisecondsSinceEpoch(utcMilliseconds, isUtc: true).toLocal();
  final localNow = now.toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final dueDay = DateTime(deadline.year, deadline.month, deadline.day);
  final days = dueDay.difference(today).inDays;
  final date = '${deadline.day.toString().padLeft(2, '0')}.${deadline.month.toString().padLeft(2, '0')}.${deadline.year}';
  if (deadline.isBefore(localNow)) return 'Überfällig · $date';
  if (days == 0) return 'Heute fällig · $date';
  if (days == 1) return 'Morgen fällig · $date';
  return 'Fällig · $date';
}
