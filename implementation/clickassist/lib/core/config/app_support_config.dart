import 'legal_config.dart';

class AppSupportConfig {
  AppSupportConfig._();

  static const String appName = 'ClickAssist';
  static const String appVersion = '1.0.0+1';

  static const String privacyPolicyUrl = LegalConfig.privacyPolicyUrl;
  static const String termsUrl = LegalConfig.responsibleUseUrl;
  static const String supportEmail = LegalConfig.supportEmail;
  static const String repositoryUrl = LegalConfig.repositoryUrl;
  static const String openSourceNotice = LegalConfig.openSourceNotice;

  static const String privacySummary = '''
ClickAssist stores your saved presets, click points, pattern steps, and onboarding choices on this device so the app can remember your setup.

ClickAssist does not include cloud sync in this project, and no analytics or crash reporting integrations were found in the current codebase.

Accessibility status, overlay availability, notification status, and battery optimization status are checked on-device so the app can show setup health and open the right Android settings screen when you ask for it.
''';

  static const String responsibleUse = '''
ClickAssist is a user-controlled automation tool.

Use automation only in apps, games, and services where it is permitted. You are responsible for following the rules of any third-party platform you use with this app.

Do not use ClickAssist for spam, fraud, fake engagement, harassment, or deceptive behavior.

The developer is not responsible for misuse by end users.
''';
}
