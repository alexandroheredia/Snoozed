import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/data/tasks_repository.dart';

/// Provides the repository used to persist and query local tasks.
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final repository = TasksRepository();
  ref.onDispose(repository.close);
  return repository;
});

/// Initializes the task repository before task streams are consumed.
final tasksInitializationProvider = FutureProvider<void>((ref) async {
  await ref.watch(tasksRepositoryProvider).initialize();
});
