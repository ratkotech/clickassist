import 'package:flutter/material.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/app_support_config.dart';
import '../../../../core/services/click_assist_platform_service.dart';
import '../widgets/clicker_section_card.dart';
import '../widgets/info_page_scaffold.dart';

class HelpSafetyPage extends StatelessWidget {
  const HelpSafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const platformService = ClickAssistPlatformService();
    return InfoPageScaffold(
      title: 'Help & Safety',
      subtitle:
          'Clear guidance for setup, permissions, privacy, and responsible use.',
      actions: [
        IconButton(
          tooltip: 'Settings & Legal',
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.settingsLegal);
          },
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
      children: [
        ClickerSectionCard(
          title: 'How To Use',
          icon: Icons.play_circle_outline_rounded,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoBullet(
                title: 'What the app does',
                body:
                    'ClickAssist runs taps and swipe steps that you configure yourself.',
              ),
              _InfoBullet(
                title: 'How to add click points',
                body:
                    'Use Pick On Screen, move the picker to the exact target in another app, and confirm it.',
              ),
              _InfoBullet(
                title: 'How start delay works',
                body:
                    'Start delay waits for the selected number of seconds before playback begins so you can switch to another app.',
              ),
              _InfoBullet(
                title: 'Sequential vs simultaneous taps',
                body:
                    'Sequential runs saved steps one after another. Simultaneous tries to dispatch multiple points in one cycle at the same time.',
              ),
              _InfoBullet(
                title: 'How presets work',
                body:
                    'Presets save the current setup, including targets, speed, delay, mode, and pattern, so you can load it again later.',
              ),
              _InfoBullet(
                title: 'How to stop automation',
                body:
                    'Use the STOP button in the app or the floating overlay controls while the automation is running.',
              ),
              _InfoBullet(
                title: 'What the floating overlay does',
                body:
                    'The overlay shows quick controls above other apps so you can start, stop, or return to settings without leaving the current screen.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ClickerSectionCard(
          title: 'Permissions Explained',
          icon: Icons.verified_user_outlined,
          child: const Column(
            children: [
              _PermissionItem(
                title: 'Accessibility service',
                body:
                    'Used only to simulate taps and swipes that you configure. You can choose not to enable it, but automation outside the app will not run without it.',
              ),
              SizedBox(height: AppSpacing.md),
              _PermissionItem(
                title: 'Display over other apps',
                body:
                    'Used for the floating overlay and on-screen target picker. You can keep it disabled if you do not want overlay controls.',
              ),
              SizedBox(height: AppSpacing.md),
              _PermissionItem(
                title: 'Notifications',
                body:
                    'Used for foreground controls and status updates while background services are active. You can choose not to enable it, but native quick controls may be limited.',
              ),
              SizedBox(height: AppSpacing.md),
              _PermissionItem(
                title: 'Battery optimization exemption',
                body:
                    'Optional reliability setting that can reduce Android background interruptions. You can leave battery optimization on if you prefer.',
              ),
              SizedBox(height: AppSpacing.md),
              _PermissionItem(
                title: 'Foreground service',
                body:
                    'Used when the overlay is active so Android keeps the service visible and user-controlled. This is tied to the app\'s visible status notification.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ClickerSectionCard(
          title: 'Safety & Responsible Use',
          icon: Icons.health_and_safety_outlined,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoBullet(
                title: 'Use only where automation is allowed',
                body:
                    'Only run ClickAssist on apps, games, and workflows where automation is permitted.',
              ),
              _InfoBullet(
                title: 'You are responsible for third-party rules',
                body:
                    'Check the rules of the service you use. ClickAssist does not verify whether automation is allowed there.',
              ),
              _InfoBullet(
                title: 'Do not misuse automation',
                body:
                    'Do not use this app for fraud, spam, abuse, fake engagement, or deceptive behavior.',
              ),
              _InfoBullet(
                title: 'Device performance may vary',
                body:
                    'Very low intervals may behave differently across devices, Android versions, or app contexts.',
              ),
              _InfoBullet(
                title: 'Simultaneous mode has platform limits',
                body:
                    'Multi-point simultaneous playback depends on Android gesture dispatch and may be limited on some devices.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ClickerSectionCard(
          title: 'Contact & Legal',
          icon: Icons.contact_support_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support email: ${AppSupportConfig.supportEmail}',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Version: ${AppSupportConfig.appVersion}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      platformService.openExternalUrl(
                        AppSupportConfig.privacyPolicyUrl,
                      );
                    },
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: const Text('Privacy Policy'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      platformService.openExternalUrl(AppSupportConfig.termsUrl);
                    },
                    icon: const Icon(Icons.gavel_rounded),
                    label: const Text('Terms / Use'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationName: AppSupportConfig.appName,
                        applicationVersion: AppSupportConfig.appVersion,
                      );
                    },
                    icon: const Icon(Icons.article_outlined),
                    label: const Text('Licenses'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppSupportConfig.openSourceNotice,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.privacySummary);
              },
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Privacy Summary'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.responsibleUse);
              },
              icon: const Icon(Icons.gavel_rounded),
              label: const Text('Responsible Use'),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  const _InfoBullet({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  const _PermissionItem({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
