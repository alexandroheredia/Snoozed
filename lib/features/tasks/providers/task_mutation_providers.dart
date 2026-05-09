// ignore_for_file: public_member_api_docs, because this file is internal.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/data/tasks_repository.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:smarttodo/features/tasks/providers/app_bootstrap_providers.dart';

final tasksControllerProvider = Provider<TasksController>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return TasksController(repository);
});

class TasksController {
  const TasksController(this._repository);

  final TasksRepository _repository;

  Future<void> addTask(Task task) {
    return _repository.addTask(task);
  }

  Future<void> updateTask(Task task) {
    return _repository.updateTask(task);
  }

  Future<void> deleteTask(String id) {
    return _repository.deleteTask(id);
  }

  Future<void> setTaskCompleted(String id, {required bool isCompleted}) {
    return _repository.setTaskCompleted(id, isCompleted: isCompleted);
  }

  Future<void> snoozeTask(Task task) {
    return _repository.snoozeTask(task);
  }

  Future<void> deleteCompletedTasks() {
    return _repository.deleteCompletedTasks();
  }
}
