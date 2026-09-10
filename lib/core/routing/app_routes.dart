abstract final class Routes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const shell = '/shell';

  static const notifications = '/notifications';
  static const taskDetail = '/task';

  // Workspace destinations
  static const settings = '/settings';
  static const profile = '/profile';

  /// Generic "not built yet" screen — pass the title via `Get.toNamed(...,
  /// arguments: '<title>')`.
  static const comingSoon = '/coming-soon';
}
