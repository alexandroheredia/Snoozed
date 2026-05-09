import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:sqflite/sqflite.dart';

/// Persists and queries tasks from the local SQLite database.
class TasksRepository {
  /// Creates a tasks repository.
  TasksRepository();

  Database? _database;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Opens the database and creates its schema when needed.
  Future<void> initialize() async {
    if (_database != null) {
      return;
    }

    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'snoozed_tasks.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            attached_link TEXT NOT NULL DEFAULT '',
            is_completed INTEGER NOT NULL DEFAULT 0,
            due_date INTEGER NOT NULL,
            times_skipped INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<Database> get _db async {
    await initialize();
    return _database!;
  }

  /// Watches all tasks, ordered with incomplete tasks first.
  Stream<List<Task>> watchAllTasks() async* {
    yield await getAllTasks();
    yield* _changes.stream.asyncMap((_) => getAllTasks());
  }

  /// Watches only incomplete tasks ordered by due date.
  Stream<List<Task>> watchPendingTasks() async* {
    yield await getPendingTasks();
    yield* _changes.stream.asyncMap((_) => getPendingTasks());
  }

  /// Returns every task in display order.
  Future<List<Task>> getAllTasks() async {
    final database = await _db;
    final rows = await database.query(
      'tasks',
      orderBy: 'is_completed ASC, due_date ASC, created_at ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  /// Returns only incomplete tasks in display order.
  Future<List<Task>> getPendingTasks() async {
    final database = await _db;
    final rows = await database.query(
      'tasks',
      where: 'is_completed = ?',
      whereArgs: const [0],
      orderBy: 'due_date ASC, created_at ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  /// Inserts a new [task].
  Future<void> addTask(Task task) async {
    final database = await _db;
    await database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyChanges();
  }

  /// Updates an existing [task].
  Future<void> updateTask(Task task) async {
    final database = await _db;
    await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    _notifyChanges();
  }

  /// Deletes the task identified by [id].
  Future<void> deleteTask(String id) async {
    final database = await _db;
    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    _notifyChanges();
  }

  /// Updates the completion state for the task identified by [id].
  Future<void> setTaskCompleted(String id, {required bool isCompleted}) async {
    final database = await _db;
    await database.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    _notifyChanges();
  }

  /// Snoozes [task] by moving its due date forward.
  Future<void> snoozeTask(Task task) async {
    final database = await _db;
    final updatedDueDate = task.dueDate.add(Duration(days: task.timesSkipped));
    await database.update(
      'tasks',
      {
        'due_date': updatedDueDate.millisecondsSinceEpoch,
        'times_skipped': task.timesSkipped + 1,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
    _notifyChanges();
  }

  /// Removes all completed tasks.
  Future<void> deleteCompletedTasks() async {
    final database = await _db;
    await database.delete(
      'tasks',
      where: 'is_completed = ?',
      whereArgs: const [1],
    );
    _notifyChanges();
  }

  void _notifyChanges() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  /// Disposes repository resources.
  Future<void> close() async {
    await _changes.close();
    await _database?.close();
    _database = null;
  }
}
