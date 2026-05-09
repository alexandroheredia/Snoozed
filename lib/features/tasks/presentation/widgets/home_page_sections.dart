import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarttodo/features/tasks/domain/task.dart';

/// Displays task-loading errors on the home screen.
class TasksErrorState extends StatelessWidget {
  /// Creates the error state widget.
  const TasksErrorState({required this.message, super.key});

  /// The error message to display.
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

/// Displays the empty state when there is no current task.
class EmptyState extends StatelessWidget {
  /// Creates the empty state widget.
  const EmptyState({
    required this.onAddTask,
    super.key,
  });

  /// Called when the user wants to create the first task.
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
          'Add a task and Snoozed will show you one thing to focus on at a '
          'time.',
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

/// Displays the single current task and its actions.
class TaskCard extends StatelessWidget {
  /// Creates a task card.
  const TaskCard({
    required this.task,
    required this.onDelete,
    required this.onComplete,
    required this.onEdit,
    required this.onOpenLink,
    required this.onSnooze,
    super.key,
  });

  /// The task currently being displayed.
  final Task task;

  /// Called when the task should be deleted.
  final Future<void> Function() onDelete;

  /// Called when the task should be completed.
  final Future<void> Function() onComplete;

  /// Called when the task should be edited.
  final VoidCallback onEdit;

  /// Called when the task link should be opened.
  final VoidCallback? onOpenLink;

  /// Called when the task should be snoozed.
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
                        label: 'Skipped ${task.timesSkipped - 1} '
                            'time${task.timesSkipped == 1 ? '' : 's'}',
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

/// Displays summary chips above the current task.
class TaskSummaryHeader extends StatelessWidget {
  /// Creates the task summary header.
  const TaskSummaryHeader({
    required this.pendingCount,
    required this.dueDate,
    required this.timesSkipped,
    super.key,
  });

  /// The number of incomplete tasks.
  final int pendingCount;

  /// The current task's due date.
  final DateTime dueDate;

  /// The number of times the current task was snoozed.
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
              label: '$pendingCount active '
                  'task${pendingCount == 1 ? '' : 's'}',
              backgroundColor: const Color.fromARGB(255, 38, 39, 58),
              foregroundColor: CupertinoColors.white,
            ),
            if (timesSkipped > 1)
              TaskPillLabel(
                label: '${timesSkipped - 1} '
                    'snooze${timesSkipped == 2 ? '' : 's'}',
                backgroundColor: const Color.fromARGB(255, 48, 49, 73),
                foregroundColor: CupertinoColors.systemGrey2,
              ),
          ],
        ),
      ],
    );
  }
}

/// Displays a rounded pill label used across the home screen.
class TaskPillLabel extends StatelessWidget {
  /// Creates a pill label.
  const TaskPillLabel({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
  });

  /// The text shown inside the pill.
  final String label;

  /// The pill background color.
  final Color backgroundColor;

  /// The pill text color.
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

/// Displays a circular action button used on the home screen.
class RoundActionButton extends StatelessWidget {
  /// Creates a round action button.
  const RoundActionButton({
    required this.onPressed,
    required this.child,
    this.size = 70,
    super.key,
  });

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// The widget shown inside the button.
  final Widget child;

  /// The button's width and height.
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

/// Formats a due date for the header summary above the task card.
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

/// Formats a due date for the pills shown on a task card.
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
