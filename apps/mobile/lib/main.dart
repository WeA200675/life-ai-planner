import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL CHECK(length(trim(title)) > 0), '
          'done INTEGER NOT NULL DEFAULT 0 CHECK(done IN (0, 1)))',
        );
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

  Future<void> setDone(int id, bool done) async {
    final db = await database;
    await db.update('tasks', {'done': done ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
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
  List<Map<String, Object?>> _tasks = [];
  bool _busy = false;
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

  Future<void> _toggle(int id, bool done) async {
    try {
      await _store.setDone(id, done);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'Änderung konnte nicht gespeichert werden.');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            Expanded(child: _tasks.isEmpty
                ? const Center(child: Text('Noch keine Aufgaben gespeichert.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      final done = task['done'] == 1;
                      return CheckboxListTile(
                        key: ValueKey(task['id']),
                        value: done,
                        title: Text(task['title'] as String),
                        onChanged: (value) => _toggle(task['id'] as int, value ?? false),
                      );
                    },
                  )),
          ]),
        ),
      );
}
