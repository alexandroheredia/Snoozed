import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarttodo/core/constants.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:smarttodo/features/tasks/presentation/widgets/home_page_sections.dart';
import 'package:smarttodo/features/tasks/presentation/widgets/task_editor_sheet.dart';
import 'package:smarttodo/features/tasks/presentation/widgets/tasks_list_sheet.dart';
import 'package:smarttodo/features/tasks/providers/task_editor_providers.dart';
import 'package:smarttodo/features/tasks/providers/task_mutation_providers.dart';
import 'package:smarttodo/features/tasks/providers/task_query_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// The main screen of Snoozed, showing a single current task at a time.
class HomePage extends ConsumerStatefulWidget {
  /// Creates the home page.
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final currentTaskAsync = ref.watch(currentTaskProvider);
    final pendingCountAsync = ref.watch(pendingCountProvider);
    final tasksController = ref.read(tasksControllerProvider);

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
          child: currentTaskAsync.when(
            loading: () => const Center(child: loadingWidget),
            error: (error, stackTrace) => TasksErrorState(
              message: error.toString(),
            ),
            data: (currentTask) {
              final pendingCount = pendingCountAsync.asData?.value ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: currentTask == null
                            ? EmptyState(onAddTask: _showAddTaskPanel)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TaskSummaryHeader(
                                    pendingCount: pendingCount,
                                    dueDate: currentTask.dueDate,
                                    timesSkipped: currentTask.timesSkipped,
                                  ),
                                  const SizedBox(height: 16),
                                  TaskCard(
                                    task: currentTask,
                                    onDelete: () async {
                                      await tasksController.deleteTask(
                                        currentTask.id,
                                      );
                                    },
                                    onComplete: () async {
                                      await tasksController.setTaskCompleted(
                                        currentTask.id,
                                        isCompleted: true,
                                      );
                                    },
                                    onEdit: () {
                                      unawaited(
                                        _showEditTaskPanel(currentTask),
                                      );
                                    },
                                    onOpenLink: currentTask.attachedLink.isEmpty
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
                                      await tasksController.snoozeTask(
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
                            RoundActionButton(
                              onPressed: () {
                                showTaskListPanel(context);
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.bars,
                                color: CupertinoColors.white,
                              ),
                            ),
                            RoundActionButton(
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
    _resetTaskEditor();
    await showTaskEditorSheet(context: context, ref: ref);
    _resetTaskEditor();
  }

  Future<void> _showEditTaskPanel(Task task) async {
    final titleController = ref.read(taskTitleControllerProvider);
    final descriptionController = ref.read(taskDescriptionControllerProvider);
    final linkController = ref.read(taskLinkControllerProvider);

    ref.read(taskBeingEditedProvider.notifier).task = task;
    titleController.text = task.title;
    descriptionController.text = task.description;
    linkController.text = task.attachedLink;

    await showTaskEditorSheet(context: context, ref: ref);
    _resetTaskEditor();
  }

  void _resetTaskEditor() {
    ref.read(taskBeingEditedProvider.notifier).task = null;
    ref.read(taskTitleControllerProvider).clear();
    ref.read(taskDescriptionControllerProvider).clear();
    ref.read(taskLinkControllerProvider).clear();
    ref.read(taskFormKeyProvider).currentState?.reset();
  }
}
