import '../../core/error/result.dart';
import '../entities/attendance.dart';

abstract interface class AttendanceRepository {
  Future<Result<AttendanceToday>> today();

  /// Most-recent day first.
  Future<Result<List<AttendanceDay>>> history();

  Future<Result<AttendanceToday>> checkIn();

  Future<Result<AttendanceToday>> checkOut();
}
