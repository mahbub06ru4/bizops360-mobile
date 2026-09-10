abstract final class Routes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const shell = '/shell';

  static const notifications = '/notifications';
  static const taskDetail = '/task';
  static const attendance = '/attendance';
  static const leave = '/leave';
  static const leaveRequest = '/leave/request';
  static const approvals = '/approvals';
  static const customerDetail = '/customer';
  static const followUps = '/follow-ups';
  static const expenses = '/expenses';
  static const expenseNew = '/expenses/new';
  static const visaDetail = '/visa/case';
  static const documents = '/documents';

  // Workspace destinations
  static const settings = '/settings';
  static const profile = '/profile';

  /// Generic "not built yet" screen — pass the title via `Get.toNamed(...,
  /// arguments: '<title>')`.
  static const comingSoon = '/coming-soon';
}
