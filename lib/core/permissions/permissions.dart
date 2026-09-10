/// The permission-name catalogue. These strings mirror the abilities the
/// backend attaches to `user.permissions`; reference `Perm.*`, never a literal,
/// so a rename is one edit and the set is discoverable.
///
/// Backend authorization stays the security authority — these only decide what
/// the app *shows*.
abstract final class Perm {
  // Organisation / people
  static const employeeView = 'employee.view';
  static const employeeManage = 'employee.manage';

  // Tasks & operations
  static const taskView = 'task.view';
  static const taskCreate = 'task.create';
  static const taskAssign = 'task.assign';

  // Attendance & leave
  static const attendanceSelf = 'attendance.self';
  static const attendanceView = 'attendance.view';
  static const leaveRequest = 'leave.request';
  static const leaveApprove = 'leave.approve';

  // Documents
  static const documentView = 'document.view';
  static const documentManage = 'document.manage';

  // CRM
  static const customerView = 'customer.view';
  static const customerManage = 'customer.manage';
  static const followUpManage = 'follow_up.manage';

  // Finance
  static const expenseSubmit = 'expense.submit';
  static const expenseApprove = 'expense.approve';
  static const invoiceView = 'invoice.view';
  static const invoiceManage = 'invoice.manage';
  static const paymentRecord = 'payment.record';

  // Travel (industry:travel)
  static const travellerView = 'traveller.view';
  static const travellerManage = 'traveller.manage';
  static const visaView = 'visa.view';
  static const visaManage = 'visa.manage';
  static const bookingView = 'booking.view';
  static const bookingManage = 'booking.manage';

  // Reports / dashboards
  static const reportsView = 'reports.view';
}

/// Named feature flags carried by `/me/bootstrap` `enabled_features`. A feature
/// can be off for a tenant even when the user holds the permission.
abstract final class Feature {
  static const attendance = 'attendance';
  static const leave = 'leave';
  static const tasks = 'tasks';
  static const crm = 'crm';
  static const expenses = 'expenses';
  static const documents = 'documents';
  static const travelVisa = 'travel_visa';
  static const travelBookings = 'travel_bookings';
  static const reports = 'reports';
}
