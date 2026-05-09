import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';

/// Provides the form key used by the add/edit task sheet.
final taskFormKeyProvider = Provider<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

/// Stores the task currently being edited, if any.
final taskBeingEditedProvider =
    NotifierProvider<TaskBeingEditedNotifier, Task?>(
  TaskBeingEditedNotifier.new,
);

/// Holds the task currently being edited in the task editor sheet.
class TaskBeingEditedNotifier extends Notifier<Task?> {
  @override
  Task? build() {
    return null;
  }

  /// The task currently being edited.
  Task? get task => state;

  /// Updates the task currently being edited.
  set task(Task? value) {
    state = value;
  }
}

/// Provides the title controller for the task editor.
final taskTitleControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

/// Provides the description controller for the task editor.
final taskDescriptionControllerProvider =
    Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

/// Provides the attached-link controller for the task editor.
final taskLinkControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});
