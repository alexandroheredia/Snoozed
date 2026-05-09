// ignore_for_file: public_member_api_docs, use_colored_box, lines_longer_than_80_chars, unnecessary_lambdas, avoid_redundant_argument_values, because this is app-internal UI code.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarttodo/core/constants.dart';
import 'package:smarttodo/features/tasks/application/delete_completed_tasks.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';
import 'package:smarttodo/features/tasks/providers/task_mutation_providers.dart';
import 'package:smarttodo/features/tasks/providers/task_query_providers.dart';

void showTaskListPanel(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, child) {
          final tasksAsync = ref.watch(allTasksProvider);
          final taskCountsAsync = ref.watch(taskCountsProvider);

          return GestureDetector(
            onTap: () => Navigator.of(sheetContext).pop(),
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.001),
              child: GestureDetector(
                onTap: () {},
                child: DraggableScrollableSheet(
                  initialChildSize: 0.72,
                  minChildSize: 0.2,
                  builder: (_, controller) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF28293d),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 15),
                          const Text(
                            'My Tasks',
                            style: TextStyle(
                              fontSize: 24,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: tasksAsync.when(
                                loading: () => loadingWidget,
                                error: (error, stackTrace) => _TaskListError(
                                  message: error.toString(),
                                ),
                                data: (tasks) {
                                  final counts = taskCountsAsync.asData?.value;
                                  final completedCount = counts?.completedCount ?? 0;
                                  final pendingCount = counts?.pendingCount ?? 0;

                                  if (tasks.isEmpty) {
                                    return const Center(
                                      child: Text('no tasks to show'),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          0,
                                          8,
                                          12,
                                        ),
                                        child: Row(
                                          children: [
                                            _CountChip(
                                              label: '$pendingCount active',
                                              color: const Color.fromARGB(
                                                255,
                                                69,
                                                71,
                                                104,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _CountChip(
                                              label:
                                                  '$completedCount completed',
                                              color: const Color.fromARGB(
                                                255,
                                                48,
                                                49,
                                                73,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          controller: controller,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: tasks.length,
                                          itemBuilder: (context, index) {
                                            final task = tasks[index];
                                            return _TaskListItem(task: task);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                color: CupertinoColors.activeGreen,
                                borderRadius: BorderRadius.circular(35),
                                onPressed: () => deleteCompletedTasks(ref),
                                child: const Text(
                                  'Remove Completed',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _TaskListError extends StatelessWidget {
  const _TaskListError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Could not load tasks.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CupertinoColors.systemGrey2,
          ),
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TaskListItem extends ConsumerWidget {
  const _TaskListItem({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(tasksControllerProvider);

    return Column(
      children: [
        Slidable(
          key: ValueKey(task.id),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                autoClose: true,
                onPressed: (_) async {
                  await controller.deleteTask(task.id);
                },
                backgroundColor: CupertinoColors.systemRed,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () async {
              await controller.setTaskCompleted(
                task.id,
                isCompleted: !task.isCompleted,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Center(
                      child: task.isCompleted
                          ? const FaIcon(
                              FontAwesomeIcons.solidCircleCheck,
                              color: CupertinoColors.activeGreen,
                              size: 24,
                            )
                          : const FaIcon(
                              FontAwesomeIcons.circle,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (task.description.isNotEmpty)
                          Text(
                            task.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey2,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDueLabel(task),
                    style: TextStyle(
                      color: task.isCompleted
                          ? CupertinoColors.systemGrey2
                          : const Color.fromARGB(255, 123, 208, 167),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

String _formatDueLabel(Task task) {
  if (task.isCompleted) {
    return 'Done';
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDate = DateTime(
    task.dueDate.year,
    task.dueDate.month,
    task.dueDate.day,
  );
  final difference = dueDate.difference(today).inDays;

  if (difference < 0) {
    return '${difference.abs()}d late';
  }
  if (difference == 0) {
    return 'Today';
  }
  if (difference == 1) {
    return 'Tomorrow';
  }
  return '${task.dueDate.month}/${task.dueDate.day}';
}
