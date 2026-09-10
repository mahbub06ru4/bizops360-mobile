/// String keys for GetX translations. Reference these, never a raw literal, so
/// every screen is bilingual from the start. `key.tr` resolves against the
/// active locale, falling back to English.
abstract final class Tr {
  static const appName = 'app_name';

  // Common
  static const retry = 'common.retry';
  static const cancel = 'common.cancel';
  static const save = 'common.save';
  static const ok = 'common.ok';
  static const somethingWrong = 'common.something_wrong';
  static const english = 'common.english';
  static const bengali = 'common.bengali';
  static const today = 'common.today';
  static const overdue = 'common.overdue';
  static const upcoming = 'common.upcoming';
  static const viewAll = 'common.view_all';
  static const seeAll = 'common.see_all';

  // Common — state views
  static const emptyTitle = 'common.empty_title';
  static const errorTitle = 'common.error_title';
  static const offlineTitle = 'common.offline_title';
  static const offlineBody = 'common.offline_body';
  static const loading = 'common.loading';

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
  static const navCustomers = 'nav.customers';
  static const navVisa = 'nav.visa';
  static const navTasks = 'nav.tasks';
  static const navMore = 'nav.more';

  // Workspace (the "More" tab)
  static const workspaceTitle = 'workspace.title';
  static const wsProfile = 'workspace.profile';
  static const wsAttendance = 'workspace.attendance';
  static const wsLeave = 'workspace.leave';
  static const wsExpenses = 'workspace.expenses';
  static const wsDocuments = 'workspace.documents';
  static const wsTeam = 'workspace.team';
  static const wsCrm = 'workspace.crm';
  static const wsReports = 'workspace.reports';
  static const wsApprovals = 'workspace.approvals';
  static const wsSettings = 'workspace.settings';
  static const wsHelp = 'workspace.help';
  static const wsSectionWork = 'workspace.section_work';
  static const wsSectionManage = 'workspace.section_manage';
  static const wsSectionAccount = 'workspace.section_account';

  // Home dashboard
  static const greetingMorning = 'home.greeting_morning';
  static const greetingAfternoon = 'home.greeting_afternoon';
  static const greetingEvening = 'home.greeting_evening';
  static const homeVisaSummary = 'home.visa_summary';
  static const homeVisaDocs = 'home.visa_docs';
  static const homeFollowUps = 'home.follow_ups';
  static const homeTicketTasks = 'home.ticket_tasks';
  static const homeMyTasks = 'home.my_tasks';
  static const homeQuickActions = 'home.quick_actions';
  static const homeQaNewCustomer = 'home.qa_new_customer';
  static const homeQaNewTask = 'home.qa_new_task';
  static const homeQaCheckIn = 'home.qa_check_in';
  static const homeQaNewBooking = 'home.qa_new_booking';
  static const homeNothingToday = 'home.nothing_today';
  static const homeVisaInProgress = 'home.visa_in_progress';
  static const homeVisaAwaitingDocs = 'home.visa_awaiting_docs';
  static const homeVisaDecisionDue = 'home.visa_decision_due';

  // Settings
  static const settingsTitle = 'settings.title';
  static const settingsAppearance = 'settings.appearance';
  static const settingsThemeSystem = 'settings.theme_system';
  static const settingsThemeLight = 'settings.theme_light';
  static const settingsThemeDark = 'settings.theme_dark';
  static const settingsLanguage = 'settings.language';

  // Placeholder copy
  static const comingSoon = 'home.coming_soon';
}
