/// A locally stored task shown by Snoozed.
class Task {
  /// Creates a task.
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.attachedLink,
    required this.isCompleted,
    required this.dueDate,
    required this.timesSkipped,
    required this.createdAt,
  });

  /// Creates a [Task] from a database row.
  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id']! as String,
      title: map['title']! as String,
      description: (map['description'] as String?) ?? '',
      attachedLink: (map['attached_link'] as String?) ?? '',
      isCompleted: ((map['is_completed'] as int?) ?? 0) == 1,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date']! as int),
      timesSkipped: (map['times_skipped'] as int?) ?? 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at']! as int,
      ),
    );
  }

  /// The stable local identifier for the task.
  final String id;

  /// The primary label shown to the user.
  final String title;

  /// The longer description for the task.
  final String description;

  /// An optional link attached to the task.
  final String attachedLink;

  /// Whether the task has been completed.
  final bool isCompleted;

  /// The date used to order and surface the task.
  final DateTime dueDate;

  /// The number of times the task has been snoozed.
  final int timesSkipped;

  /// When the task was originally created.
  final DateTime createdAt;

  /// Returns a copy of this task with the provided fields replaced.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? attachedLink,
    bool? isCompleted,
    DateTime? dueDate,
    int? timesSkipped,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      attachedLink: attachedLink ?? this.attachedLink,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      timesSkipped: timesSkipped ?? this.timesSkipped,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts this task into a map suitable for SQLite persistence.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'attached_link': attachedLink,
      'is_completed': isCompleted ? 1 : 0,
      'due_date': dueDate.millisecondsSinceEpoch,
      'times_skipped': timesSkipped,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
