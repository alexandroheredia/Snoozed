// ignore_for_file: public_member_api_docs, sort_constructors_first, lines_longer_than_80_chars, because this is an app-internal model.

class Task {
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

  final String id;
  final String title;
  final String description;
  final String attachedLink;
  final bool isCompleted;
  final DateTime dueDate;
  final int timesSkipped;
  final DateTime createdAt;

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
}
