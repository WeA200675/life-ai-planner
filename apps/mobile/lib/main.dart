import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'offline_task_plan_adapter.dart';
import 'local_task_schema.dart';

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
      version: 3,
      onCreate: (db, version) => createTaskSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await migrateTasksV1ToV2(db);
        if (oldVersion < 3) await migrateTasksV2ToV3(db);
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
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
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
    final editController = TextEditingController(text: title);
    String? updated;
    try {
      updated = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Aufgabe bearbeiten'),
          content: TextField(
            controller: editController,
            autofocus: true,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Aufgabentitel'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, editController.text),
              child: const Text('Speichern'),
            ),
          ],
        ),
      );
    } finally {
      editController.dispose();
    }
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
    final minutesController = TextEditingController(
      text: (task['minutes'] as int?)?.toString() ?? '',
    );
    final priorityController = TextEditingController(
      text: (task['priority'] as int? ?? 0).toString(),
    );
    ({int? minutes, int priority})? selected;
    try {
      selected = await showDialog<({int? minutes, int priority})>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Planungswerte bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dauer in Minuten (1–1440)',
                  helperText: 'Leer = vorläufig 30 Minuten',
                ),
              ),
              TextField(
                controller: priorityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Priorität (0–10)',
                ),
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
                final durationText = minutesController.text.trim();
                final minutes = durationText.isEmpty
                    ? null : int.tryParse(durationText);
                final priority = int.tryParse(priorityController.text.trim());
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
    } finally {
      minutesController.dispose();
      priorityController.dispose();
    }
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

  Future<void> _showDayPreview() async {
    if (_busy) return;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 8);
    final end = DateTime(now.year, now.month, now.day, 18);
    try {
      final plan = previewLocalTasks(start, end, _tasks);
      if (!mounted) return;
      final names = {
        for (final task in _tasks) task['id'].toString(): task['title'] as String,
      };
      String hhmm(DateTime time) =>
          time.hour.toString().padLeft(2, '0') + ':' +
          time.minute.toString().padLeft(2, '0');
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Tagesplanung – Vorschau'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text('08:00–18:00 · Individuelle Dauern; ohne Angabe 30 Minuten'),
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
                  for (final id in plan.deferred) Text(names[id] ?? id),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Schließen'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _error = 'Tagesvorschau konnte nicht erstellt werden.');
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
