// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, because this is app-internal UI code.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';

class TasksErrorState extends StatelessWidget {
  const TasksErrorState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Could not load your tasks.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CupertinoColors.systemGrey2,
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.onAddTask,
    super.key,
  });

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

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onDelete,
    required this.onComplete,
    required this.onEdit,
    required this.onOpenLink,
    required this.onSnooze,
    super.key,
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
                  const TaskPillLabel(
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
                      TaskPillLabel(
                        label: formatDueLabel(task.dueDate),
                        backgroundColor: const Color.fromARGB(255, 48, 49, 73),
                        foregroundColor: CupertinoColors.systemGrey2,
                      ),
                      TaskPillLabel(
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
            RoundActionButton(
              onPressed: () {
                unawaited(onDelete());
              },
              child: const FaIcon(
                FontAwesomeIcons.trashCan,
                color: CupertinoColors.systemRed,
              ),
            ),
            RoundActionButton(
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
            RoundActionButton(
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

class TaskSummaryHeader extends StatelessWidget {
  const TaskSummaryHeader({
    required this.pendingCount,
    required this.dueDate,
    required this.timesSkipped,
    super.key,
  });

  final int pendingCount;
  final DateTime dueDate;
  final int timesSkipped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          formatDueHeadline(dueDate),
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
            TaskPillLabel(
              label: '$pendingCount active task${pendingCount == 1 ? '' : 's'}',
              backgroundColor: const Color.fromARGB(255, 38, 39, 58),
              foregroundColor: CupertinoColors.white,
            ),
            if (timesSkipped > 1)
              TaskPillLabel(
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

class TaskPillLabel extends StatelessWidget {
  const TaskPillLabel({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
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

class RoundActionButton extends StatelessWidget {
  const RoundActionButton({
    required this.onPressed,
    required this.child,
    this.size = 70,
    super.key,
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

String formatDueHeadline(DateTime dueDate) {
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

String formatDueLabel(DateTime dueDate) {
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
