import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'translation_keys.dart';

/// English and বাংলা ship together. English is the fallback for any key a
/// translation misses.
class AppTranslations extends Translations {
  static const Locale english = Locale('en', 'US');
  static const Locale bengali = Locale('bn', 'BD');
  static const Locale fallback = english;

  static Locale? fromCode(String? code) => switch (code) {
    'en' => english,
    'bn' => bengali,
    _ => null,
  };

  static String codeOf(Locale locale) => locale.languageCode;

  @override
  Map<String, Map<String, String>> get keys => {'en_US': _en, 'bn_BD': _bn};

  static const Map<String, String> _en = {
    Tr.appName: 'BizOps 360',
    Tr.retry: 'Retry',
    Tr.cancel: 'Cancel',
    Tr.save: 'Save',
    Tr.somethingWrong: 'Something went wrong.',
    Tr.english: 'English',
    Tr.bengali: 'বাংলা',
    Tr.signInTitle: 'Sign in to your workspace',
    Tr.email: 'Email',
    Tr.password: 'Password',
    Tr.signIn: 'Sign in',
    Tr.forgotPassword: 'Forgot password?',
    Tr.activationHint:
        'First time here? Open the activation link we emailed you. Accounts are created by your company admin.',
    Tr.signOut: 'Sign out',
    Tr.sessionEnded: 'Your session has ended. Sign in again.',
    Tr.navHome: 'Home',
    Tr.navTeam: 'Team',
    Tr.navTasks: 'Tasks',
    Tr.navDesk: 'Desk',
    Tr.navCrm: 'CRM',
    Tr.navInsights: 'Insights',
    Tr.navMore: 'More',
    Tr.myDay: 'My day',
    Tr.myTeam: 'My team',
    Tr.comingSoon: 'Coming soon',
    Tr.signedInAs: 'Signed in as',
  };

  static const Map<String, String> _bn = {
    Tr.appName: 'BizOps 360',
    Tr.retry: 'আবার চেষ্টা করুন',
    Tr.cancel: 'বাতিল',
    Tr.save: 'সংরক্ষণ',
    Tr.somethingWrong: 'কিছু একটা সমস্যা হয়েছে।',
    Tr.english: 'English',
    Tr.bengali: 'বাংলা',
    Tr.signInTitle: 'আপনার ওয়ার্কস্পেসে সাইন ইন করুন',
    Tr.email: 'ইমেইল',
    Tr.password: 'পাসওয়ার্ড',
    Tr.signIn: 'সাইন ইন',
    Tr.forgotPassword: 'পাসওয়ার্ড ভুলে গেছেন?',
    Tr.activationHint:
        'প্রথমবার? আমরা যে অ্যাক্টিভেশন লিংক ইমেইল করেছি সেটি খুলুন। অ্যাকাউন্ট তৈরি করেন আপনার কোম্পানির অ্যাডমিন।',
    Tr.signOut: 'সাইন আউট',
    Tr.sessionEnded: 'আপনার সেশন শেষ হয়ে গেছে। আবার সাইন ইন করুন।',
    Tr.navHome: 'হোম',
    Tr.navTeam: 'টিম',
    Tr.navTasks: 'কাজ',
    Tr.navDesk: 'ডেস্ক',
    Tr.navCrm: 'সিআরএম',
    Tr.navInsights: 'ইনসাইটস',
    Tr.navMore: 'আরও',
    Tr.myDay: 'আমার দিন',
    Tr.myTeam: 'আমার টিম',
    Tr.comingSoon: 'শীঘ্রই আসছে',
    Tr.signedInAs: 'সাইন ইন করেছেন',
  };
}
