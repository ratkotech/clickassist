import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/app_support_config.dart';
import '../../../../core/services/click_assist_platform_service.dart';
import '../../../../widgets/brand_logo.dart';
import '../providers/clicker_controller.dart';
import '../widgets/clicker_section_card.dart';
import '../widgets/info_page_scaffold.dart';
import '../widgets/settings_action_tile.dart';

class SettingsLegalPage extends ConsumerWidget {
  const SettingsLegalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clickerControllerProvider.notifier);
    const platformService = ClickAssistPlatformService();

    Future<void> showInfo(String message) async {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> sendSupportEmail({
      required String subject,
      required String body,
      required String failureMessage,
    }) async {
      final opened = await platformService.composeSupportEmail(
        email: AppSupportConfig.supportEmail,
        subject: subject,
        body: body,
      );
      if (!opened) {
        await showInfo(failureMessage);
      }
    }

    final deviceLabel = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };

    final feedbackBody =
        '''
Hi,

I would like to share the following feedback:

---

App version: ${AppSupportConfig.appFullVersion}
Device: $deviceLabel
''';

    final bugBody =
        '''
Hi,

I encountered a bug:

Steps to reproduce:
1.
2.
3.

Expected behavior:
Actual behavior:

---

App version: ${AppSupportConfig.appFullVersion}
Device: $deviceLabel
''';

    Future<bool> confirmAction({
      required String title,
      required String body,
      required String actionLabel,
      required Future<void> Function() onConfirm,
      bool isDestructive = false,
    }) async {
      final approved = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: isDestructive
                    ? FilledButton.styleFrom(backgroundColor: Colors.redAccent)
                    : null,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(actionLabel),
              ),
            ],
          );
        },
      );

      if (approved == true) {
        await onConfirm();
        return true;
      }
      return false;
    }

    return InfoPageScaffold(
      title: 'Settings & Legal',
      subtitle:
          'Manage support links, data actions, and the in-app transparency surfaces for ClickAssist.',
      children: [
        ClickerSectionCard(
          title: 'Help & Legal',
          icon: Icons.policy_outlined,
          child: Column(
            children: [
              SettingsActionTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Safety',
                description:
                    'Open setup guidance, permission explanations, and safety notes.',
                label: 'Open',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.helpSafety);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                description:
                    'Open the full privacy policy URL configured for this app.',
                label: 'Open',
                onPressed: () {
                  platformService.openExternalUrl(
                    AppSupportConfig.privacyPolicyUrl,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.gavel_rounded,
                title: 'Responsible Use',
                description:
                    'Review the in-app responsible use guidance and open the configured terms link.',
                label: 'Open',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.responsibleUse);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.open_in_new_rounded,
                title: 'Responsible Use Link',
                description:
                    'Open the external responsible-use or terms URL configured for the app.',
                label: 'Open',
                onPressed: () {
                  platformService.openExternalUrl(AppSupportConfig.termsUrl);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.mail_outline_rounded,
                title: 'Send Feedback',
                description:
                    'Share product feedback through your default email app.',
                label: 'Send',
                onPressed: () async {
                  await sendSupportEmail(
                    subject: '${AppSupportConfig.appName} Feedback',
                    body: feedbackBody,
                    failureMessage: 'No email app was found on this device.',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                description:
                    'Send a prefilled bug report email with reproduction steps.',
                label: 'Report',
                onPressed: () async {
                  await sendSupportEmail(
                    subject: '${AppSupportConfig.appName} Bug Report',
                    body: bugBody,
                    failureMessage: 'No email app was found on this device.',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.article_outlined,
                title: 'Open-Source Licenses',
                description:
                    'Review the Flutter and package licenses used by this app.',
                label: 'Open',
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: AppSupportConfig.appName,
                    applicationVersion: AppSupportConfig.appVersion,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ClickerSectionCard(
          title: 'Data Actions',
          icon: Icons.storage_rounded,
          child: Column(
            children: [
              SettingsActionTile(
                icon: Icons.file_download_outlined,
                title: 'Export Presets',
                description:
                    'Copy the current presets as JSON so you can review or back them up.',
                label: 'Copy',
                onPressed: () async {
                  final json = await controller.exportPresetsJson();
                  await Clipboard.setData(ClipboardData(text: json));
                  await showInfo('Preset JSON copied to clipboard.');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.layers_clear_outlined,
                title: 'Clear Presets',
                description:
                    'Remove all saved presets while keeping your Android permission settings unchanged.',
                label: 'Clear',
                onPressed: () async {
                  await confirmAction(
                    title: 'Clear presets?',
                    body:
                        'This removes all saved presets from this device. Your current live configuration will stay open until you change it.',
                    actionLabel: 'Clear presets',
                    isDestructive: true,
                    onConfirm: controller.clearPresets,
                  );
                },
                isDestructive: true,
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsActionTile(
                icon: Icons.restart_alt_rounded,
                title: 'Reset App Data',
                description:
                    'Clear local presets, onboarding state, and in-app configuration without changing Android system permissions.',
                label: 'Reset',
                onPressed: () async {
                  final didReset = await confirmAction(
                    title: 'Reset local app data?',
                    body:
                        'This stops active automation, clears local data, and shows onboarding again next time. Android permission switches remain under system settings.',
                    actionLabel: 'Reset data',
                    isDestructive: true,
                    onConfirm: controller.resetAppData,
                  );
                  if (didReset) {
                    await showInfo('Local app data reset.');
                  }
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ClickerSectionCard(
          title: 'About ClickAssist',
          icon: Icons.info_outline_rounded,
          child: const _AppInfoContent(),
        ),
      ],
    );
  }
}

class _AppInfoContent extends StatelessWidget {
  const _AppInfoContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandLogo.mark(size: 92),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppSupportConfig.appName,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryBright,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppSupportConfig.aboutDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmallReadable,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Version ${AppSupportConfig.appVersion}',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        const _AppInfoRow(
          label: 'Status',
          value: AppSupportConfig.projectStatus,
        ),
        const _AppInfoRow(
          label: 'Developer',
          value: AppSupportConfig.developerName,
        ),
        const _AppInfoRow(
          label: 'Support',
          value: AppSupportConfig.supportEmail,
        ),
        const _AppInfoRow(
          label: 'Privacy',
          value: AppSupportConfig.privacyPolicyUrl,
        ),
        const _AppInfoRow(
          label: 'Responsible use',
          value: AppSupportConfig.termsUrl,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppSupportConfig.openSourceNotice,
          style: AppTextStyles.bodySmallReadable,
        ),
        const SizedBox(height: AppSpacing.sm),
        const _AppInfoRow(
          label: 'Repository',
          value: AppSupportConfig.repositoryUrl,
          bottomSpacing: 0,
        ),
      ],
    );
  }
}

class _AppInfoRow extends StatelessWidget {
  const _AppInfoRow({
    required this.label,
    required this.value,
    this.bottomSpacing = AppSpacing.sm,
  });

  final String label;
  final String value;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.labelUppercase),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(value, style: AppTextStyles.bodySmallReadable),
        ],
      ),
    );
  }
}
