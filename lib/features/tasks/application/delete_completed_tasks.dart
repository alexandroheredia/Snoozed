// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, because this is an app-internal helper.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/providers/task_mutation_providers.dart';

Future<void> deleteCompletedTasks(WidgetRef ref) async {
  await ref.read(tasksControllerProvider).deleteCompletedTasks();
}
