import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ClickAssist',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap automation',
          style: AppTextStyles.bodyLarge,
        ),
      ],
    );
  }
}