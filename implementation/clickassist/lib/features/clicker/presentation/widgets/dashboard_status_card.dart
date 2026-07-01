import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

enum DashboardStatusTone { blocking, warning, ready, running }

class DashboardStatusCard extends StatelessWidget {
  const DashboardStatusCard({
    super.key,
    required this.tone,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.advisoryMessage,
  });

  final DashboardStatusTone tone;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? advisoryMessage;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final showAction = actionLabel != null && onAction != null;
    final showAdvisory = advisoryMessage?.trim().isNotEmpty ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            AppColors.surface.withValues(alpha: 0.94),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.78), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusIcon(tone: tone),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusPill(label: _pillLabel, color: accent),
                    const SizedBox(height: AppSpacing.sm),
                    Text(title, style: AppTextStyles.titleMediumCompact),
                    const SizedBox(height: AppSpacing.xs),
                    Text(message, style: AppTextStyles.bodyMediumReadable),
                  ],
                ),
              ),
              if (showAction) ...[
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
          if (showAdvisory) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Optional reliability tip',
                          style: AppTextStyles.statusLabel.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          advisoryMessage!,
                          style: AppTextStyles.bodySmallReadable.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color get _accentColor {
    return switch (tone) {
      DashboardStatusTone.blocking => AppColors.primary,
      DashboardStatusTone.warning => AppColors.warning,
      DashboardStatusTone.ready => AppColors.success,
      DashboardStatusTone.running => AppColors.primaryBright,
    };
  }

  String get _pillLabel {
    return switch (tone) {
      DashboardStatusTone.blocking => 'Required setup',
      DashboardStatusTone.warning => 'Attention',
      DashboardStatusTone.ready => 'Ready',
      DashboardStatusTone.running => 'Running',
    };
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.tone});

  final DashboardStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final icon = switch (tone) {
      DashboardStatusTone.blocking => Icons.shield_outlined,
      DashboardStatusTone.warning => Icons.info_outline_rounded,
      DashboardStatusTone.ready => Icons.check_rounded,
      DashboardStatusTone.running => Icons.play_arrow_rounded,
    };
    final color = switch (tone) {
      DashboardStatusTone.blocking => AppColors.primary,
      DashboardStatusTone.warning => AppColors.warning,
      DashboardStatusTone.ready => AppColors.success,
      DashboardStatusTone.running => AppColors.primaryBright,
    };

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3,
        ),
        child: Text(
          label,
          style: AppTextStyles.statusLabel.copyWith(color: color),
        ),
      ),
    );
  }
}
