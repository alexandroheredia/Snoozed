import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:smarttodo/features/tasks/providers/app_bootstrap_providers.dart';

/// Streams every task in display order.
final allTasksProvider = StreamProvider<List<Task>>((ref) async* {
  await ref.watch(tasksInitializationProvider.future);
  yield* ref.watch(tasksRepositoryProvider).watchAllTasks();
});

/// Streams only incomplete tasks in display order.
final pendingTasksProvider = StreamProvider<List<Task>>((ref) async* {
  await ref.watch(tasksInitializationProvider.future);
  yield* ref.watch(tasksRepositoryProvider).watchPendingTasks();
});

/// Exposes the single current task shown on the home screen.
final currentTaskProvider = Provider<AsyncValue<Task?>>((ref) {
  final pendingTasks = ref.watch(pendingTasksProvider);
  return pendingTasks.whenData((tasks) => tasks.isEmpty ? null : tasks.first);
});

/// Exposes the number of incomplete tasks.
final pendingCountProvider = Provider<AsyncValue<int>>((ref) {
  final pendingTasks = ref.watch(pendingTasksProvider);
  return pendingTasks.whenData((tasks) => tasks.length);
});

/// Exposes counts used by the tasks sheet summary chips.
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

/// Aggregate counts for pending and completed tasks.
class TaskCounts {
  /// Creates a set of task counts.
  const TaskCounts({
    required this.pendingCount,
    required this.completedCount,
  });

  /// The number of incomplete tasks.
  final int pendingCount;

  /// The number of completed tasks.
  final int completedCount;
}
