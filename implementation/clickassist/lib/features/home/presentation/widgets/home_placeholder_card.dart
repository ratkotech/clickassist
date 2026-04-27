import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';

class HomePlaceholderCard extends StatelessWidget {
  const HomePlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.stroke),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project structure ready',
            style: AppTextStyles.titleLarge,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Next we will build the home screen from components: stats bar, start button, status banner, delay toggle, pattern selector, click mode, and speed selector.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}