// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, use_colored_box, because this is app-internal UI code.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarttodo/data/tasks_repository.dart';
import 'package:smarttodo/models/task.dart';
import 'package:smarttodo/shared/constants.dart';
import 'package:smarttodo/task_list/tasks_list.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  final TextEditingController _taskLinkController = TextEditingController();
  final GlobalKey<FormState> _taskFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _taskLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (_) => FocusScope.of(context).unfocus(),
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0xFF28293d),
        navigationBar: const CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          border: Border(bottom: BorderSide(color: Colors.transparent)),
          backgroundColor: Color(0xFF28293d),
          middle: Text(
            'Snoozed',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Task>>(
            stream: TasksRepository.instance.watchPendingTasks(),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? <Task>[];
              final currentTask = tasks.isEmpty ? null : tasks.first;
              final pendingCount = tasks.length;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: snapshot.connectionState ==
                                ConnectionState.waiting
                            ? loadingWidget
                            : currentTask == null
                                ? _EmptyState(onAddTask: _showAddTaskPanel)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _TaskSummaryHeader(
                                        pendingCount: pendingCount,
                                        dueDate: currentTask.dueDate,
                                        timesSkipped: currentTask.timesSkipped,
                                      ),
                                      const SizedBox(height: 16),
                                      _TaskCard(
                                        task: currentTask,
                                        onDelete: () async {
                                          await TasksRepository.instance
                                              .deleteTask(
                                            currentTask.id,
                                          );
                                        },
                                        onComplete: () async {
                                          await TasksRepository.instance
                                              .setTaskCompleted(
                                            currentTask.id,
                                            isCompleted: true,
                                          );
                                        },
                                        onEdit: () {
                                          unawaited(
                                            _showEditTaskPanel(currentTask),
                                          );
                                        },
                                        onOpenLink: currentTask
                                                .attachedLink.isEmpty
                                            ? null
                                            : () {
                                                unawaited(
                                                  _launchInBrowser(
                                                    Uri.parse(
                                                      currentTask.attachedLink,
                                                    ),
                                                  ),
                                                );
                                              },
                                        onSnooze: () async {
                                          await TasksRepository.instance
                                              .snoozeTask(
                                            currentTask,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _RoundActionButton(
                              onPressed: () {
                                showTaskListPanel(context);
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.bars,
                                color: CupertinoColors.white,
                              ),
                            ),
                            _RoundActionButton(
                              onPressed: () {
                                unawaited(_showAddTaskPanel(context));
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.plus,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Version $appVersionNumber',
                          style: TextStyle(
                            color: Color.fromARGB(255, 80, 80, 113),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      unawaited(
        Fluttertoast.showToast(
          timeInSecForIosWeb: 5,
          msg:
              "Can't open this link, make sure it's like this: https://www.website.com/",
          fontSize: 16,
        ),
      );
    }
  }

  Future<void> _showAddTaskPanel(BuildContext context) async {
    _taskTitleController.clear();
    _taskDescriptionController.clear();
    _taskLinkController.clear();
    await _showTaskEditorSheet();
  }

  Future<void> _showEditTaskPanel(Task task) async {
    _taskTitleController.text = task.title;
    _taskDescriptionController.text = task.description;
    _taskLinkController.text = task.attachedLink;
    await _showTaskEditorSheet(task: task);
  }

  Future<void> _showTaskEditorSheet({Task? task}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isEditing = task != null;

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
                        key: _taskFormKey,
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
                              controller: _taskTitleController,
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
                              controller: _taskDescriptionController,
                              maxLength: 1000,
                              maxLines: 8,
                              placeholder: 'Describe this task',
                            ),
                            const SizedBox(height: 15),
                            _TaskTextField(
                              controller: _taskLinkController,
                              maxLength: 500,
                              maxLines: 1,
                              placeholder: 'Paste a link for this task',
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: CupertinoButton(
                                    color:
                                        const Color.fromARGB(255, 18, 18, 27),
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
                                      final form = _taskFormKey.currentState;
                                      if (form == null || !form.validate()) {
                                        return;
                                      }

                                      final title =
                                          _taskTitleController.text.trim();
                                      final description =
                                          _taskDescriptionController.text
                                              .trim();
                                      final attachedLink =
                                          _taskLinkController.text.trim();

                                      if (task == null) {
                                        await TasksRepository.instance.addTask(
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
                                        await TasksRepository.instance
                                            .updateTask(
                                          task.copyWith(
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTask});

  final Future<void> Function(BuildContext context) onAddTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/celebration_task_list_empty.png',
          height: 180,
        ),
        const SizedBox(height: 20),
        const Text(
          'Nothing urgent right now',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Add a task and Snoozed will show you one thing to focus on at a time.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CupertinoColors.systemGrey2,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        CupertinoButton.filled(
          onPressed: () {
            unawaited(onAddTask(context));
          },
          child: const Text('Create your first task'),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onDelete,
    required this.onComplete,
    required this.onEdit,
    required this.onOpenLink,
    required this.onSnooze,
  });

  final Task task;
  final Future<void> Function() onDelete;
  final Future<void> Function() onComplete;
  final VoidCallback onEdit;
  final VoidCallback? onOpenLink;
  final Future<void> Function() onSnooze;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 57, 59, 85),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _TaskPillLabel(
                    label: 'Next up',
                    backgroundColor: Color.fromARGB(255, 69, 71, 104),
                    foregroundColor: CupertinoColors.white,
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    task.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SelectableText(
                      task.description,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                  if (task.attachedLink.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.link,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: onOpenLink,
                            child: Text(
                              task.attachedLink,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 60, 153, 252),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TaskPillLabel(
                        label: _formatDueLabel(task.dueDate),
                        backgroundColor: const Color.fromARGB(255, 48, 49, 73),
                        foregroundColor: CupertinoColors.systemGrey2,
                      ),
                      _TaskPillLabel(
                        label:
                            'Skipped ${task.timesSkipped - 1} time${task.timesSkipped == 1 ? '' : 's'}',
                        backgroundColor: const Color.fromARGB(255, 48, 49, 73),
                        foregroundColor: CupertinoColors.systemGrey2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: const Color.fromARGB(255, 18, 18, 27),
                borderRadius: BorderRadius.circular(35),
                onPressed: onEdit,
                child: const SizedBox(
                  height: 52,
                  width: 52,
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.pen,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _RoundActionButton(
              onPressed: () {
                unawaited(onDelete());
              },
              child: const FaIcon(
                FontAwesomeIcons.trashCan,
                color: CupertinoColors.systemRed,
              ),
            ),
            _RoundActionButton(
              size: 100,
              onPressed: () {
                unawaited(onComplete());
              },
              child: const FaIcon(
                FontAwesomeIcons.check,
                color: CupertinoColors.activeGreen,
                size: 40,
              ),
            ),
            _RoundActionButton(
              onPressed: () {
                unawaited(onSnooze());
              },
              child: const FaIcon(
                FontAwesomeIcons.share,
                color: Color.fromARGB(255, 255, 179, 0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskSummaryHeader extends StatelessWidget {
  const _TaskSummaryHeader({
    required this.pendingCount,
    required this.dueDate,
    required this.timesSkipped,
  });

  final int pendingCount;
  final DateTime dueDate;
  final int timesSkipped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatDueHeadline(dueDate),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CupertinoColors.systemGrey2,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _TaskPillLabel(
              label: '$pendingCount active task${pendingCount == 1 ? '' : 's'}',
              backgroundColor: const Color.fromARGB(255, 38, 39, 58),
              foregroundColor: CupertinoColors.white,
            ),
            if (timesSkipped > 1)
              _TaskPillLabel(
                label:
                    '${timesSkipped - 1} snooze${timesSkipped == 2 ? '' : 's'}',
                backgroundColor: const Color.fromARGB(255, 48, 49, 73),
                foregroundColor: CupertinoColors.systemGrey2,
              ),
          ],
        ),
      ],
    );
  }
}

class _TaskPillLabel extends StatelessWidget {
  const _TaskPillLabel({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.onPressed,
    required this.child,
    this.size = 70,
  });

  final VoidCallback onPressed;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 18, 18, 27),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

String _formatDueHeadline(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final normalizedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final difference = normalizedDueDate.difference(today).inDays;

  if (difference < 0) {
    final overdueDays = difference.abs();
    return overdueDays == 1
        ? 'Overdue by 1 day'
        : 'Overdue by $overdueDays days';
  }
  if (difference == 0) {
    return 'Due today';
  }
  if (difference == 1) {
    return 'Due tomorrow';
  }
  return 'Due in $difference days';
}

String _formatDueLabel(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final normalizedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final difference = normalizedDueDate.difference(today).inDays;

  if (difference < 0) {
    final overdueDays = difference.abs();
    return overdueDays == 1 ? '1 day overdue' : '$overdueDays days overdue';
  }
  if (difference == 0) {
    return 'Today';
  }
  if (difference == 1) {
    return 'Tomorrow';
  }
  return '${dueDate.month}/${dueDate.day}/${dueDate.year}';
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
