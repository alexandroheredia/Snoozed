import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/providers/task_mutation_providers.dart';

/// Deletes all completed tasks using the task mutations controller.
Future<void> deleteCompletedTasks(WidgetRef ref) async {
  await ref.read(tasksControllerProvider).deleteCompletedTasks();
}
