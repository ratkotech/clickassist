import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class ClickerDashboardHeader extends StatelessWidget {
  const ClickerDashboardHeader({
    super.key,
    required this.actionsPerSecond,
    required this.clicks,
    required this.totalClicks,
    required this.onRefresh,
    required this.onOpenHelp,
    required this.onOpenSettings,
  });

  final double actionsPerSecond;
  final int clicks;
  final int totalClicks;
  final VoidCallback onRefresh;
  final VoidCallback onOpenHelp;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Click Assist',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Tap automation', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                _HeaderActionButton(
                  icon: Icons.help_outline_rounded,
                  tooltip: 'Help & Safety',
                  onPressed: onOpenHelp,
                ),
                _HeaderActionButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'Settings & Legal',
                  onPressed: onOpenSettings,
                ),
                _HeaderActionButton(
                  icon: Icons.sync_rounded,
                  tooltip: 'Refresh status',
                  onPressed: onRefresh,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: actionsPerSecond == 0
                      ? '0'
                      : actionsPerSecond.toStringAsFixed(
                          actionsPerSecond >= 10 ? 0 : 1,
                        ),
                  label: 'APS',
                  highlight: false,
                ),
              ),
              const _DividerLine(),
              Expanded(
                child: _StatTile(
                  value: '$clicks',
                  label: 'Actions',
                  highlight: true,
                ),
              ),
              const _DividerLine(),
              Expanded(
                child: _StatTile(
                  value: '$totalClicks',
                  label: 'Total',
                  highlight: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.stroke),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.highlight,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.stroke);
  }
}
