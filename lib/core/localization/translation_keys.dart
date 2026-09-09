/// String keys for GetX translations. Reference these, never a raw literal, so
/// every screen is bilingual from the start. `key.tr` resolves against the
/// active locale, falling back to English.
abstract final class Tr {
  static const appName = 'app_name';

  // Common
  static const retry = 'common.retry';
  static const cancel = 'common.cancel';
  static const save = 'common.save';
  static const somethingWrong = 'common.something_wrong';
  static const english = 'common.english';
  static const bengali = 'common.bengali';

  // Auth
  static const signInTitle = 'auth.sign_in_title';
  static const email = 'auth.email';
  static const password = 'auth.password';
  static const signIn = 'auth.sign_in';
  static const forgotPassword = 'auth.forgot_password';
  static const activationHint = 'auth.activation_hint';
  static const signOut = 'auth.sign_out';
  static const sessionEnded = 'auth.session_ended';

  // Shell / nav
  static const navHome = 'nav.home';
  static const navTeam = 'nav.team';
  static const navTasks = 'nav.tasks';
  static const navDesk = 'nav.desk';
  static const navCrm = 'nav.crm';
  static const navInsights = 'nav.insights';
  static const navMore = 'nav.more';

  // Home (placeholder copy for the scaffold)
  static const myDay = 'home.my_day';
  static const myTeam = 'home.my_team';
  static const comingSoon = 'home.coming_soon';
  static const signedInAs = 'home.signed_in_as';
}
