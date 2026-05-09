// ignore_for_file: public_member_api_docs, because this file is internal.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:smarttodo/features/tasks/providers/app_bootstrap_providers.dart';

final allTasksProvider = StreamProvider<List<Task>>((ref) async* {
  await ref.watch(tasksInitializationProvider.future);
  yield* ref.watch(tasksRepositoryProvider).watchAllTasks();
});

final pendingTasksProvider = StreamProvider<List<Task>>((ref) async* {
  await ref.watch(tasksInitializationProvider.future);
  yield* ref.watch(tasksRepositoryProvider).watchPendingTasks();
});

final currentTaskProvider = Provider<AsyncValue<Task?>>((ref) {
  final pendingTasks = ref.watch(pendingTasksProvider);
  return pendingTasks.whenData((tasks) => tasks.isEmpty ? null : tasks.first);
});

final pendingCountProvider = Provider<AsyncValue<int>>((ref) {
  final pendingTasks = ref.watch(pendingTasksProvider);
  return pendingTasks.whenData((tasks) => tasks.length);
});

final taskCountsProvider = Provider<AsyncValue<TaskCounts>>((ref) {
  final allTasks = ref.watch(allTasksProvider);
  return allTasks.whenData((tasks) {
    final completedCount = tasks.where((task) => task.isCompleted).length;
    return TaskCounts(
      pendingCount: tasks.length - completedCount,
      completedCount: completedCount,
    );
  });
});

class TaskCounts {
  const TaskCounts({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;
}
