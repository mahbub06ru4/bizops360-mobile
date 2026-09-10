import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, late, earlyLeave, absent, onLeave, holiday }

/// A single day's attendance record.
class AttendanceDay extends Equatable {
  const AttendanceDay({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;

  Duration? get worked => (checkIn != null && checkOut != null)
      ? checkOut!.difference(checkIn!)
      : null;

  @override
  List<Object?> get props => [date, status, checkIn, checkOut];
}

/// Today's live state — drives the check-in / check-out card.
class AttendanceToday extends Equatable {
  const AttendanceToday({this.checkIn, this.checkOut});

  final DateTime? checkIn;
  final DateTime? checkOut;

  bool get isCheckedIn => checkIn != null && checkOut == null;
  bool get isDone => checkIn != null && checkOut != null;

  AttendanceToday copyWith({DateTime? checkIn, DateTime? checkOut}) =>
      AttendanceToday(
        checkIn: checkIn ?? this.checkIn,
        checkOut: checkOut ?? this.checkOut,
      );

  @override
  List<Object?> get props => [checkIn, checkOut];
}
