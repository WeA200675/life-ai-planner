import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'offline_task_plan_adapter.dart';
import 'offline_day_planner.dart';
import 'plan_snapshot_store.dart';
import 'local_task_schema.dart';
import 'planner_theme.dart';
import 'deadline_presentation.dart';
import 'deferred_task_explanation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlannerApp());
}

class LocalTasks {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    return _db = await openDatabase(
      p.join(root, 'life_ai_planner.db'),
      version: 4,
      onCreate: (db, version) async {
        await createTaskSchema(db);
        await createPlanSnapshotSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await migrateTasksV1ToV2(db);
        if (oldVersion < 3) await migrateTasksV2ToV3(db);
        if (oldVersion < 4) await createPlanSnapshotSchema(db);
      },
    );
  }

  Future<List<Map<String, Object?>>> all() async {
    final db = await database;
    return db.query('tasks', orderBy: 'done ASC, id DESC');
  }

  Future<void> add(String title) async {
    final clean = title.trim();
    if (clean.isEmpty || clean.length > 500) {
      throw ArgumentError('Task title must contain 1–500 characters');
    }
    final db = await database;
    await db.insert('tasks', {'title': clean, 'done': 0});
  }

  Future<void> setPlanningMetadata(int id, {int? minutes, int priority = 0}) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'Must be positive');
    if (minutes != null && (minutes < 1 || minutes > 1440)) {
      throw ArgumentError.value(minutes, 'minutes', 'Must be 1–1440');
    }
    if (priority < 0 || priority > 10) {
      throw ArgumentError.value(priority, 'priority', 'Must be 0–10');
    }
    final db = await database;
    final changed = await db.update(
      'tasks', {'minutes': minutes, 'priority': priority},
      where: 'id = ?', whereArgs: [id],
    );
    if (changed != 1) throw StateError('Task not found or update was not unique');
  }

  /// Stores an optional deadline as UTC epoch milliseconds, without network.
  /// Passing null explicitly clears an existing deadline.
  Future<void> setDeadline(int id, DateTime? deadline) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'Must be positive');
    final utcMs = deadline?.toUtc().millisecondsSinceEpoch;
    if (utcMs != null && utcMs <= 0) {
      throw ArgumentError.value(deadline, 'deadline', 'Must be after Unix epoch');
    }
    final db = await database;
    final changed = await db.update(
      'tasks', {'deadline_utc_ms': utcMs},
      where: 'id = ?', whereArgs: [id],
    );
    if (changed != 1) throw StateError('Task not found or update was not unique');
  }

  Future<void> rename(int id, String title) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'Must be positive');
    final clean = title.trim();
    if (clean.isEmpty || clean.length > 500) {
      throw ArgumentError('Task title must contain 1–500 characters');
    }
    final db = await database;
    final changed = await db.update('tasks', {'title': clean},
        where: 'id = ?', whereArgs: [id]);
    if (changed != 1) {
      throw StateError('Task not found or update was not unique');
    }
  }

  Future<void> setDone(int id, bool done) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'Must be positive');
    final db = await database;
    final changed = await db.update('tasks', {'done': done ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
    if (changed != 1) {
      throw StateError('Task not found or update was not unique');
    }
  }

  Future<bool> delete(int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'Must be positive');
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]) == 1;
  }

  Future<int> acceptPlan(DayPlan plan, DateTime start, DateTime end,
      List<Map<String, Object?>> expectedTasks) async =>
      PlanSnapshotStore(await database).accept(
          plan, start, end, expectedTasks: expectedTasks);

  Future<List<SavedPlan>> planHistory({int limit = 30, int offset = 0}) async =>
      PlanSnapshotStore(await database).history(limit: limit, offset: offset);

  Future<List<SavedPlan>> planHistoryBefore(int id, {int limit = 30}) async =>
      PlanSnapshotStore(await database).historyBefore(id, limit: limit);

  Future<SavedPlan?> planById(int id) async =>
      PlanSnapshotStore(await database).byId(id);

  Future<SavedPlan?> latestPlan() async =>
      PlanSnapshotStore(await database).latest();

  Future<bool> undoPlan(int id) async =>
      PlanSnapshotStore(await database).undoLatest(id);

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

enum TaskView { open, completed, all }

List<Map<String, Object?>> visibleTasks(
    List<Map<String, Object?>> tasks, TaskView view, [String query = '']) {
  final needle = query.trim().toLowerCase();
  return tasks.where((task) {
    if (needle.isNotEmpty &&
        !(task['title'] as String).toLowerCase().contains(needle)) {
      return false;
    }
    final done = task['done'] == 1;
    return switch (view) {
      TaskView.open => !done,
      TaskView.completed => done,
      TaskView.all => true,
    };
  }).toList(growable: false);
}

/// Counts all locally loaded tasks, independent of search and filter state.
({int open, int completed, int total}) taskCounts(
    List<Map<String, Object?>> tasks) {
  final completed = tasks.where((task) => task['done'] == 1).length;
  return (open: tasks.length - completed, completed: completed, total: tasks.length);
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Life AI Planner',
        theme: PlannerTheme.dark,
        home: const TaskScreen(),
      );
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _store = LocalTasks();
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  String _search = '';
  List<Map<String, Object?>> _tasks = [];
  bool _busy = false;
  TaskView _view = TaskView.open;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final tasks = await _store.all();
      if (mounted) setState(() { _tasks = tasks; _error = null; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Lokale Datenbank nicht verfügbar.');
    }
  }

  Future<void> _add() async {
    if (_busy) return;
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _store.add(title);
      _controller.clear();
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'Aufgabe konnte nicht gespeichert werden.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(int id, String title) async {
    if (_busy) return;
    String draft = title;
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aufgabe bearbeiten'),
        content: TextFormField(
          initialValue: title,
          autofocus: true,
          maxLength: 500,
          onChanged: (value) => draft = value,
          decoration: const InputDecoration(labelText: 'Aufgabentitel'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, draft),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (updated == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _store.rename(id, updated);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'Aufgabe konnte nicht geändert werden.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editPlanningMetadata(Map<String, Object?> task) async {
    if (_busy) return;
    String durationDraft = (task['minutes'] as int?)?.toString() ?? '';
    String priorityDraft = (task['priority'] as int? ?? 0).toString();
    final selected = await showDialog<({int? minutes, int priority})>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Planungswerte bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: durationDraft,
              keyboardType: TextInputType.number,
              onChanged: (value) => durationDraft = value,
              decoration: const InputDecoration(
                labelText: 'Dauer in Minuten (1–1440)',
                helperText: 'Leer = vorläufig 30 Minuten',
              ),
            ),
            TextFormField(
              initialValue: priorityDraft,
              keyboardType: TextInputType.number,
              onChanged: (value) => priorityDraft = value,
              decoration: const InputDecoration(labelText: 'Priorität (0–10)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              final durationText = durationDraft.trim();
              final minutes = durationText.isEmpty ? null : int.tryParse(durationText);
              final priority = int.tryParse(priorityDraft.trim());
              if ((durationText.isNotEmpty &&
                      (minutes == null || minutes < 1 || minutes > 1440)) ||
                  priority == null || priority < 0 || priority > 10) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Dauer oder Priorität ungültig.')),
                );
                return;
              }
              Navigator.pop(dialogContext, (minutes: minutes, priority: priority));
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (selected == null || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      await _store.setPlanningMetadata(
        task['id'] as int,
        minutes: selected.minutes,
        priority: selected.priority,
      );
      await _refresh();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Planungswerte konnten nicht gespeichert werden.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editDeadline(Map<String, Object?> task) async {
    if (_busy) return;
    final id = task['id'] as int;
    final stored = task['deadline_utc_ms'] as int?;
    final initial = stored == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(stored, isUtc: true).toLocal();
    final selected = await showDatePicker(
      context: context,
      initialDate: safeDeadlinePickerInitialDate(initial),
      firstDate: DateTime(1971),
      lastDate: DateTime(2100),
      helpText: 'Fälligkeitsdatum wählen',
    );
    if (!mounted || selected == null || _busy) return;
    setState(() => _busy = true);
    try {
      // A date-only deadline is inclusive until the end of the selected day.
      final deadline = DateTime(selected.year, selected.month, selected.day + 1)
          .subtract(const Duration(milliseconds: 1));
      await _store.setDeadline(id, deadline);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'Fälligkeit konnte nicht gespeichert werden.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearDeadline(int id) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _store.setDeadline(id, null);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'Fälligkeit konnte nicht entfernt werden.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete(int id, String title) async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aufgabe löschen?'),
        content: Text('„$title“ wird dauerhaft aus diesem Gerät entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _store.delete(id);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'Aufgabe konnte nicht gelöscht werden.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showDayPreview({bool remaining = false}) async {
    if (_busy) return;
    final now = DateTime.now();
    final start = remaining ? now : DateTime(now.year, now.month, now.day, 8);
    final end = DateTime(now.year, now.month, now.day, 18);
    if (!start.isBefore(end)) {
      if (mounted) setState(() => _error = 'Der Planungstag ist bereits beendet.');
      return;
    }
    try {
      final previewRows = [
        for (final row in _tasks) Map<String, Object?>.from(row),
      ];
      final plan = remaining
          ? replanLocalTasks(start, end, previewRows)
          : previewLocalTasks(start, end, previewRows);
      if (!mounted) return;
      final names = {
        for (final task in _tasks) task['id'].toString(): task['title'] as String,
      };
      String hhmm(DateTime time) =>
          time.hour.toString().padLeft(2, '0') + ':' +
          time.minute.toString().padLeft(2, '0');
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(remaining ? 'Resttag – Neuplanung' : 'Tagesplanung – Vorschau'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(remaining
                    ? 'Ab jetzt bis 18:00 · Nur offene Aufgaben · Keine Speicherung'
                    : '08:00–18:00 · Individuelle Dauern; ohne Angabe 30 Minuten'),
                Text('Planbudget: ' + plan.budgetMinutes.toString() +
                    ' Minuten · Freie Reserve: ' + plan.reservedMinutes.toString() + ' Minuten'),
                for (final block in plan.blocks)
                  ListTile(
                    dense: true,
                    title: Text(names[block.id] ?? block.id),
                    subtitle: Text(hhmm(block.start) + '–' + hhmm(block.end)),
                  ),
                if (plan.deferred.isNotEmpty) ...[
                  const Text('Nicht eingeplant:'),
                  for (final id in plan.deferred)
                    ListTile(
                      dense: true,
                      title: Text(names[id] ?? id),
                      subtitle: Text(deferredTaskExplanation(plan, id)),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Schließen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Plan übernehmen'),
            ),
          ],
        ),
      );
      if (accepted == true && mounted) {
        final id = await _store.acceptPlan(plan, start, end, previewRows);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Tagesplan lokal gespeichert.'),
          action: SnackBarAction(label: 'Rückgängig', onPressed: () async {
            try {
              final undone = await _store.undoPlan(id);
              if (mounted && !undone) {
                setState(() => _error = 'Plan wurde inzwischen geändert.');
              }
            } catch (_) {
              if (mounted) setState(() => _error = 'Rückgängig fehlgeschlagen.');
            }
          }),
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Tagesvorschau konnte nicht erstellt werden.');
    }
  }

  Future<void> _showPlanHistory() async {
    if (_busy) return;
    const pageSize = 30;
    final entries = <SavedPlan>[];
    var loading = false;
    var hasMore = true;
    String? historyError;
    try {
      final initial = await _store.planHistory(limit: pageSize);
      entries.addAll(initial);
      hasMore = initial.length == pageSize;
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (historyContext) => StatefulBuilder(
          builder: (historyContext, updateDialog) => AlertDialog(
            title: const Text('Planhistorie'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (entries.isEmpty)
                    const Text('Noch keine gespeicherten Tagespläne.'),
                  for (final entry in entries)
                    ListTile(
                      title: Text('Plan #${entry.id}'),
                      subtitle: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                          entry.createdUtcMs, isUtc: true,
                        ).toLocal().toString(),
                      ),
                      onTap: () async {
                        try {
                          final selected = await _store.planById(entry.id);
                          if (!mounted || !historyContext.mounted) return;
                          if (selected == null) {
                            updateDialog(() => historyError =
                                'Plan wurde zwischenzeitlich entfernt.');
                            return;
                          }
                          await showDialog<void>(
                            context: historyContext,
                            builder: (detailContext) => AlertDialog(
                              title: Text('Plan #${selected.id}'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    for (final block in selected.blocks)
                                      ListTile(
                                        title: Text(block.id),
                                        subtitle: Text(
                                          '${TimeOfDay.fromDateTime(block.start.toLocal()).format(detailContext)}'
                                          ' – ${TimeOfDay.fromDateTime(block.end.toLocal()).format(detailContext)}',
                                        ),
                                      ),
                                    if (selected.blocks.isEmpty)
                                      const Text('Keine Zeitblöcke gespeichert.'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(detailContext),
                                  child: const Text('Schließen'),
                                ),
                              ],
                            ),
                          );
                        } catch (_) {
                          if (historyContext.mounted) {
                            updateDialog(() =>
                                historyError = 'Plan konnte nicht geladen werden.');
                          }
                        }
                      },
                    ),
                  if (historyError != null)
                    Text(historyError!, style: TextStyle(
                      color: Theme.of(historyContext).colorScheme.error,
                    )),
                  if (hasMore)
                    TextButton.icon(
                      onPressed: loading ? null : () async {
                        updateDialog(() {
                          loading = true;
                          historyError = null;
                        });
                        try {
                          final next = await _store.planHistoryBefore(
                            entries.last.id, limit: pageSize,
                          );
                          if (!historyContext.mounted) return;
                          updateDialog(() {
                            final known = entries.map((e) => e.id).toSet();
                            entries.addAll(next.where((e) => !known.contains(e.id)));
                            hasMore = next.length == pageSize;
                            loading = false;
                          });
                        } catch (_) {
                          if (historyContext.mounted) {
                            updateDialog(() {
                              loading = false;
                              historyError = 'Weitere Pläne konnten nicht geladen werden.';
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.expand_more),
                      label: Text(loading ? 'Lade…' : 'Weitere 30 Pläne laden'),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(historyContext),
                child: const Text('Schließen'),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _error = 'Planhistorie nicht verfügbar.');
    }
  }

  Future<void> _showSavedPlan() async {
    if (_busy) return;
    try {
      final saved = await _store.latestPlan();
      if (!mounted) return;
      if (saved == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Noch kein Tagesplan gespeichert.')),
        );
        return;
      }
      final names = {
        for (final task in _tasks) task['id'].toString(): task['title'] as String,
      };
      final undo = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Gespeicherter Plan #${saved.id}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final block in saved.blocks)
                  ListTile(
                    title: Text(names[block.id] ?? block.id),
                    subtitle: Text(
                      '${TimeOfDay.fromDateTime(block.start.toLocal()).format(dialogContext)}'
                      ' – ${TimeOfDay.fromDateTime(block.end.toLocal()).format(dialogContext)}',
                    ),
                  ),
                if (saved.blocks.isEmpty)
                  const Text('Dieser Plan enthält keine Zeitblöcke.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Schließen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Letzten Plan rückgängig machen'),
            ),
          ],
        ),
      );
      if (undo != true || !mounted) return;
      final removed = await _store.undoPlan(saved.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(removed
            ? 'Vorheriger Plan wiederhergestellt.'
            : 'Ein neuerer Plan wurde gespeichert; bitte erneut öffnen.'),
      ));
    } catch (_) {
      if (mounted) setState(() => _error = 'Gespeicherter Plan nicht verfügbar.');
    }
  }

  Future<void> _toggle(int id, bool done) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _store.setDone(id, done);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'Änderung konnte nicht gespeichert werden.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = visibleTasks(_tasks, _view, _search);
    final counts = taskCounts(_tasks);
    return Scaffold(
        appBar: AppBar(title: const Text('Life AI Planner – Offline')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              Expanded(child: TextField(
                controller: _controller,
                maxLength: 500,
                onSubmitted: (_) => _add(),
                decoration: const InputDecoration(
                  labelText: 'Neue Aufgabe',
                  hintText: 'Aufgabe als Text eingeben',
                ),
              )),
              IconButton(
                tooltip: 'Aufgabe speichern',
                onPressed: _busy ? null : _add,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ]),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                labelText: 'Aufgaben suchen',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isEmpty ? null : IconButton(
                  tooltip: 'Suche zurücksetzen',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            Semantics(
              label: 'Aufgabenstatistik',
              child: Text(
                'Offen: ${counts.open} · Erledigt: ${counts.completed} · Gesamt: ${counts.total}',
                key: const ValueKey('offline-task-counts'),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _busy ? null : _showDayPreview,
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Tagesvorschau'),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _busy ? null : () => _showDayPreview(remaining: true),
                icon: const Icon(Icons.update),
                label: const Text('Resttag neu planen'),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _busy ? null : _showSavedPlan,
                icon: const Icon(Icons.history),
                label: const Text('Gespeicherten Plan anzeigen'),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _busy ? null : _showPlanHistory,
                icon: const Icon(Icons.list_alt),
                label: const Text('Planhistorie'),
              ),
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            SegmentedButton<TaskView>(
              segments: const [
                ButtonSegment(value: TaskView.open, label: Text('Offen')),
                ButtonSegment(value: TaskView.completed, label: Text('Erledigt')),
                ButtonSegment(value: TaskView.all, label: Text('Alle')),
              ],
              selected: {_view},
              onSelectionChanged: (values) => setState(() => _view = values.first),
            ),
            Expanded(child: shown.isEmpty
                ? Center(child: Text(_tasks.isEmpty
                    ? 'Noch keine Aufgaben gespeichert.'
                    : 'Keine passenden Aufgaben gefunden.'))
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, index) {
                      final task = shown[index];
                      final done = task['done'] == 1;
                      return CheckboxListTile(
                        key: ValueKey(task['id']),
                        value: done,
                        title: Text(task['title'] as String),
                        subtitle: task['deadline_utc_ms'] is int
                            ? Text(deadlineLabel(task['deadline_utc_ms'] as int, DateTime.now()))
                            : null,
                        onChanged: _busy ? null : (value) => _toggle(task['id'] as int, value ?? false),
                        secondary: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Aufgabe bearbeiten',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: _busy ? null : () => _edit(
                                task['id'] as int, task['title'] as String),
                            ),
                            IconButton(
                              tooltip: 'Dauer und Priorität bearbeiten',
                              icon: const Icon(Icons.tune),
                              onPressed: _busy ? null : () => _editPlanningMetadata(task),
                            ),
                            IconButton(
                              tooltip: 'Fälligkeit festlegen',
                              icon: const Icon(Icons.event_outlined),
                              onPressed: _busy ? null : () => _editDeadline(task),
                            ),
                            if (task['deadline_utc_ms'] != null)
                              IconButton(
                                tooltip: 'Fälligkeit entfernen',
                                icon: const Icon(Icons.event_busy_outlined),
                                onPressed: _busy ? null : () => _clearDeadline(task['id'] as int),
                              ),
                            IconButton(
                          tooltip: 'Aufgabe löschen',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _busy ? null : () => _confirmDelete(
                            task['id'] as int, task['title'] as String),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
          ]),
        ),
      );
}
}
