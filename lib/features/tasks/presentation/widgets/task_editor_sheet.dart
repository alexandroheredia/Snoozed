// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, use_colored_box, because this is app-internal UI code.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smarttodo/core/constants.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:smarttodo/features/tasks/providers/task_editor_providers.dart';
import 'package:smarttodo/features/tasks/providers/task_mutation_providers.dart';

Future<void> showTaskEditorSheet({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final task = ref.read(taskBeingEditedProvider);
  final isEditing = task != null;
  final taskFormKey = ref.read(taskFormKeyProvider);
  final taskTitleController = ref.read(taskTitleControllerProvider);
  final taskDescriptionController = ref.read(
    taskDescriptionControllerProvider,
  );
  final taskLinkController = ref.read(taskLinkControllerProvider);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return GestureDetector(
        onTap: () => Navigator.of(sheetContext).pop(),
        child: Container(
          color: const Color.fromRGBO(0, 0, 0, 0.001),
          child: GestureDetector(
            onTap: () {},
            child: DraggableScrollableSheet(
              initialChildSize: 0.78,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF28293d),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      24,
                      20,
                      MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                    ),
                    child: Form(
                      key: taskFormKey,
                      child: Column(
                        children: [
                          Text(
                            isEditing ? 'Edit Task' : 'Add New Task',
                            style: const TextStyle(
                              fontSize: 24,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _TaskTextField(
                            controller: taskTitleController,
                            maxLength: 65,
                            maxLines: 1,
                            placeholder: 'Name this task',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'please type something first';
                              }
                              if (value.trim().length < 3) {
                                return 'must be at least 3 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _TaskTextField(
                            controller: taskDescriptionController,
                            maxLength: 1000,
                            maxLines: 8,
                            placeholder: 'Describe this task',
                          ),
                          const SizedBox(height: 15),
                          _TaskTextField(
                            controller: taskLinkController,
                            maxLength: 500,
                            maxLines: 1,
                            placeholder: 'Paste a link for this task',
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  color: const Color.fromARGB(255, 18, 18, 27),
                                  borderRadius: BorderRadius.circular(35),
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoButton(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(35),
                                  onPressed: () async {
                                    final form = taskFormKey.currentState;
                                    if (form == null || !form.validate()) {
                                      return;
                                    }

                                    final title = taskTitleController.text.trim();
                                    final description =
                                        taskDescriptionController.text.trim();
                                    final attachedLink =
                                        taskLinkController.text.trim();

                                    final tasksController = ref.read(
                                      tasksControllerProvider,
                                    );
                                    final taskBeingEdited = ref.read(
                                      taskBeingEditedProvider,
                                    );

                                    if (taskBeingEdited == null) {
                                      await tasksController.addTask(
                                        Task(
                                          id: generateTaskDocID(),
                                          title: title,
                                          description: description,
                                          attachedLink: attachedLink,
                                          isCompleted: false,
                                          dueDate: DateTime.now(),
                                          timesSkipped: 1,
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                      unawaited(
                                        Fluttertoast.showToast(
                                          timeInSecForIosWeb: 3,
                                          msg: 'Task added!',
                                          fontSize: 16,
                                        ),
                                      );
                                    } else {
                                      await tasksController.updateTask(
                                        taskBeingEdited.copyWith(
                                          title: title,
                                          description: description,
                                          attachedLink: attachedLink,
                                        ),
                                      );
                                      unawaited(
                                        Fluttertoast.showToast(
                                          timeInSecForIosWeb: 3,
                                          msg: 'Task updated!',
                                          fontSize: 16,
                                        ),
                                      );
                                    }

                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                    }
                                  },
                                  child: Text(
                                    isEditing ? 'Save' : 'Add Task',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 18, 18, 27),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _TaskTextField extends StatelessWidget {
  const _TaskTextField({
    required this.controller,
    required this.maxLength,
    required this.maxLines,
    required this.placeholder,
    this.validator,
  });

  final TextEditingController controller;
  final int maxLength;
  final int maxLines;
  final String placeholder;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 62, 64, 93),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CupertinoTextFormFieldRow(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLength: maxLength,
        maxLines: maxLines,
        placeholder: placeholder,
        validator: validator,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 62, 64, 93),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
