import 'offline_day_planner.dart';

/// Human-readable, offline explanation for a deferred task.
/// The scheduler remains the authority; no task or deadline is changed.
String deferredTaskExplanation(DayPlan plan, String taskId) {
  if (!plan.deferred.contains(taskId)) {
    throw ArgumentError.value(taskId, 'taskId', 'Task is not deferred');
  }
  final prefix = '$taskId: ';
  final reasons = plan.conflicts.where((item) => item.startsWith(prefix)).toList();
  if (reasons.length != 1) {
    return 'Nicht eingeplant: Planungskonflikt. Aufgabe bleibt gespeichert.';
  }
  final reason = reasons.single.substring(prefix.length);
  switch (reason) {
    case 'buffer budget exceeded':
      return 'Nicht eingeplant: 30%-Reserve bzw. Planbudget ausgeschöpft. Aufgabe bleibt gespeichert.';
    case 'no feasible time slot':
      return 'Nicht eingeplant: Kein passendes Zeitfenster vor der Fälligkeit oder zwischen Fixterminen. Aufgabe bleibt gespeichert.';
    default:
      return 'Nicht eingeplant: Planungskonflikt. Aufgabe bleibt gespeichert.';
  }
}
