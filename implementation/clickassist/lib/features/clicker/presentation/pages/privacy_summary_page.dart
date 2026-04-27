import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/app_support_config.dart';
import '../../../../core/services/click_assist_platform_service.dart';
import '../widgets/clicker_section_card.dart';
import '../widgets/info_page_scaffold.dart';

class PrivacySummaryPage extends StatelessWidget {
  const PrivacySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const platformService = ClickAssistPlatformService();
    return InfoPageScaffold(
      title: 'Privacy Summary',
      subtitle:
          'A short in-app summary of what this project stores and what it does not send off-device.',
      children: [
        ClickerSectionCard(
          title: 'What Is Stored',
          icon: Icons.save_outlined,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrivacyRow(
                label: 'Saved locally',
                body:
                    'Presets, click points, pattern steps, and onboarding state are stored on this device.',
              ),
              SizedBox(height: AppSpacing.md),
              _PrivacyRow(
                label: 'Checked on-device',
                body:
                    'Accessibility, overlay, notification, and battery-optimization status are read locally to show setup health.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ClickerSectionCard(
          title: 'What Was Not Found',
          icon: Icons.cloud_off_rounded,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrivacyRow(
                label: 'No cloud sync found',
                body:
                    'This codebase does not show cloud account sync for click points, presets, or settings.',
              ),
              SizedBox(height: AppSpacing.md),
              _PrivacyRow(
                label: 'No analytics found',
                body:
                    'No analytics SDK or telemetry service was found in the current project files reviewed here.',
              ),
              SizedBox(height: AppSpacing.md),
              _PrivacyRow(
                label: 'No crash reporting found',
                body:
                    'No crash-reporting integration was found in the current codebase review.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        ClickerSectionCard(
          title: 'Project Summary',
          icon: Icons.fact_check_outlined,
          child: Text(
            AppSupportConfig.privacySummary,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            FilledButton.icon(
              onPressed: () {
                platformService.openExternalUrl(
                  AppSupportConfig.privacyPolicyUrl,
                );
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open Privacy Policy'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppSupportConfig.openSourceNotice,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(body, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
