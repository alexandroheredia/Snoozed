// ignore_for_file: public_member_api_docs, because this file is internal.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/data/tasks_repository.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final repository = TasksRepository();
  ref.onDispose(repository.close);
  return repository;
});

final tasksInitializationProvider = FutureProvider<void>((ref) async {
  await ref.watch(tasksRepositoryProvider).initialize();
});
