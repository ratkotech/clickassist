import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/app_support_config.dart';
import '../../../../core/services/click_assist_platform_service.dart';
import '../widgets/clicker_section_card.dart';
import '../widgets/info_page_scaffold.dart';

class ResponsibleUsePage extends StatelessWidget {
  const ResponsibleUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    const platformService = ClickAssistPlatformService();
    return InfoPageScaffold(
      title: 'Responsible Use',
      subtitle:
          'Use automation transparently, only where it is permitted, and only for user-controlled workflows.',
      children: [
        ClickerSectionCard(
          title: 'Responsible Use',
          icon: Icons.gavel_rounded,
          child: Text(
            AppSupportConfig.responsibleUse,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        FilledButton.icon(
          onPressed: () {
            platformService.openExternalUrl(AppSupportConfig.termsUrl);
          },
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Open Responsible Use Link'),
        ),
      ],
    );
  }
}
