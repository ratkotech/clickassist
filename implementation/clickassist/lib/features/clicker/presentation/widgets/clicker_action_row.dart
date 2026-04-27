import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class ClickerActionRow extends StatelessWidget {
  const ClickerActionRow({
    super.key,
    required this.isRunning,
    required this.onToggleRunning,
    required this.onAddClickPoint,
  });

  final bool isRunning;
  final VoidCallback onToggleRunning;
  final VoidCallback onAddClickPoint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onToggleRunning,
            style: FilledButton.styleFrom(
              backgroundColor: isRunning ? AppColors.danger : AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            icon: Icon(
              isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(
              isRunning ? 'Stop Clicker' : 'Start Clicker',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.background,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddClickPoint,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.stroke),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add Click Point'),
          ),
        ),
      ],
    );
  }
}
