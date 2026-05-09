import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/data/tasks_repository.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:smarttodo/features/tasks/providers/app_bootstrap_providers.dart';

/// Provides the task mutations controller used by the UI.
final tasksControllerProvider = Provider<TasksController>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return TasksController(repository);
});

/// Handles write operations for the tasks feature.
class TasksController {
  /// Creates a controller backed by the given [TasksRepository].
  const TasksController(this._repository);

  final TasksRepository _repository;

  /// Inserts a new task into local storage.
  Future<void> addTask(Task task) {
    return _repository.addTask(task);
  }

  /// Persists changes to an existing task.
  Future<void> updateTask(Task task) {
    return _repository.updateTask(task);
  }

  /// Deletes the task with the given [id].
  Future<void> deleteTask(String id) {
    return _repository.deleteTask(id);
  }

  /// Marks a task as complete or incomplete.
  Future<void> setTaskCompleted(String id, {required bool isCompleted}) {
    return _repository.setTaskCompleted(id, isCompleted: isCompleted);
  }

  /// Snoozes a task by pushing its due date forward.
  Future<void> snoozeTask(Task task) {
    return _repository.snoozeTask(task);
  }

  /// Removes every completed task from local storage.
  Future<void> deleteCompletedTasks() {
    return _repository.deleteCompletedTasks();
  }
}
