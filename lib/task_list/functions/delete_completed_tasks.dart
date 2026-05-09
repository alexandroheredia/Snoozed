// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, because this is an app-internal helper.

import 'package:smarttodo/data/tasks_repository.dart';

Future<void> deleteCompletedTasks() async {
  await TasksRepository.instance.deleteCompletedTasks();
}
