import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class ClickerHeaderCard extends StatelessWidget {
  const ClickerHeaderCard({
    super.key,
    required this.isRunning,
    required this.clickPointCount,
    required this.intervalMs,
  });

  final bool isRunning;
  final int clickPointCount;
  final int intervalMs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: const LinearGradient(
          colors: [Color(0xFF173061), Color(0xFF0B1530)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isRunning
                  ? AppColors.success.withValues(alpha: 0.18)
                  : AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isRunning ? 'Automation Active' : 'Ready to Start',
              style: AppTextStyles.bodySmall.copyWith(
                color: isRunning ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Clicker Control', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tune the tap cadence, manage click points, and launch your run from one focused control surface.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: _MetricChip(label: 'Interval', value: '$intervalMs ms'),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricChip(
                  label: 'Click Points',
                  value: '$clickPointCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.statValue),
        ],
      ),
    );
  }
}
