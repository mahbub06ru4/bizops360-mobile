import 'package:equatable/equatable.dart';

enum TaskStatus { open, inProgress, blocked, done }

enum TaskPriority { low, normal, high, urgent }

class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.description,
    this.dueDate,
    this.assigneeName,
    this.subtasksTotal = 0,
    this.subtasksDone = 0,
    this.commentCount = 0,
  });

  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? assigneeName;
  final int subtasksTotal;
  final int subtasksDone;
  final int commentCount;

  bool get isDone => status == TaskStatus.done;

  bool get isOverdue {
    final due = dueDate;
    if (due == null || isDone) return false;
    final now = DateTime.now();
    return due.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool isDueToday() {
    final due = dueDate;
    if (due == null) return false;
    final now = DateTime.now();
    return due.year == now.year && due.month == now.month && due.day == now.day;
  }

  double get subtaskProgress =>
      subtasksTotal == 0 ? 0 : subtasksDone / subtasksTotal;

  TaskItem copyWith({TaskStatus? status}) => TaskItem(
    id: id,
    title: title,
    description: description,
    status: status ?? this.status,
    priority: priority,
    dueDate: dueDate,
    assigneeName: assigneeName,
    subtasksTotal: subtasksTotal,
    subtasksDone: subtasksDone,
    commentCount: commentCount,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    dueDate,
    assigneeName,
    subtasksTotal,
    subtasksDone,
    commentCount,
  ];
}
