import '../../core/error/result.dart';
import '../entities/task_comment.dart';
import '../entities/task_item.dart';

abstract interface class TaskRepository {
  /// Tasks assigned to the current user, most-urgent first.
  Future<Result<List<TaskItem>>> myTasks();

  Future<Result<TaskItem>> byId(String id);

  Future<Result<TaskItem>> updateStatus(String id, TaskStatus status);

  /// Manager action — create and (optionally) assign a task.
  Future<Result<TaskItem>> create({
    required String title,
    required TaskPriority priority,
    DateTime? dueDate,
    String? assigneeName,
  });

  /// The comment thread on a task, oldest first.
  Future<Result<List<TaskComment>>> comments(String taskId);

  Future<Result<TaskComment>> addComment(String taskId, String body);
}
