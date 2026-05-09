// ignore_for_file: public_member_api_docs, because this is app-internal.

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';

final taskFormKeyProvider = Provider<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

final taskBeingEditedProvider =
    NotifierProvider<TaskBeingEditedNotifier, Task?>(
  TaskBeingEditedNotifier.new,
);

class TaskBeingEditedNotifier extends Notifier<Task?> {
  @override
  Task? build() {
    return null;
  }

  Task? get task => state;

  set task(Task? value) {
    state = value;
  }
}

final taskTitleControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final taskDescriptionControllerProvider =
    Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final taskLinkControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});
