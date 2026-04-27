import 'package:flutter/material.dart';

import '../../features/clicker/presentation/pages/clicker_page.dart';
import '../../features/clicker/presentation/pages/help_safety_page.dart';
import '../../features/clicker/presentation/pages/privacy_summary_page.dart';
import '../../features/clicker/presentation/pages/responsible_use_page.dart';
import '../../features/clicker/presentation/pages/settings_legal_page.dart';
import '../../features/clicker/presentation/pages/startup_shell_page.dart';

class AppRouter {
  static const String home = '/';
  static const String clicker = '/clicker';
  static const String helpSafety = '/help-safety';
  static const String privacySummary = '/privacy-summary';
  static const String responsibleUse = '/responsible-use';
  static const String settingsLegal = '/settings-legal';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const StartupShellPage(),
          settings: settings,
        );

      case clicker:
        return MaterialPageRoute(
          builder: (_) => const ClickerPage(),
          settings: settings,
        );

      case helpSafety:
        return MaterialPageRoute(
          builder: (_) => const HelpSafetyPage(),
          settings: settings,
        );

      case privacySummary:
        return MaterialPageRoute(
          builder: (_) => const PrivacySummaryPage(),
          settings: settings,
        );

      case responsibleUse:
        return MaterialPageRoute(
          builder: (_) => const ResponsibleUsePage(),
          settings: settings,
        );

      case settingsLegal:
        return MaterialPageRoute(
          builder: (_) => const SettingsLegalPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
          settings: settings,
        );
    }
  }
}
