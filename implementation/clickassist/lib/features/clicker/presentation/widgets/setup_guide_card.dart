import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class SetupGuideCard extends StatelessWidget {
  const SetupGuideCard({
    super.key,
    required this.accessibilityEnabled,
    required this.overlayPermissionEnabled,
    required this.notificationsEnabled,
    required this.batteryOptimizationIgnored,
    required this.onOpenAccessibility,
    required this.onOpenOverlay,
    required this.onOpenNotifications,
    required this.onOpenBatteryOptimization,
    required this.onRefresh,
  });

  final bool accessibilityEnabled;
  final bool overlayPermissionEnabled;
  final bool notificationsEnabled;
  final bool batteryOptimizationIgnored;
  final VoidCallback onOpenAccessibility;
  final VoidCallback onOpenOverlay;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenBatteryOptimization;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _SetupStepData(
        keyBase: 'accessibility',
        title: 'Accessibility',
        description:
            'Required to run configured taps and swipes in other apps.',
        complete: accessibilityEnabled,
        actionLabel: 'Open settings',
        onOpen: onOpenAccessibility,
        icon: Icons.accessibility_new_rounded,
      ),
      _SetupStepData(
        keyBase: 'overlay',
        title: 'Overlay permission',
        description: 'Required for floating controls and target picking.',
        complete: overlayPermissionEnabled,
        actionLabel: 'Open settings',
        onOpen: onOpenOverlay,
        icon: Icons.picture_in_picture_alt_rounded,
      ),
      _SetupStepData(
        keyBase: 'notifications',
        title: 'Notifications',
        description:
            'Keeps foreground service status and quick controls visible.',
        complete: notificationsEnabled,
        actionLabel: 'Open settings',
        onOpen: onOpenNotifications,
        icon: Icons.notifications_active_outlined,
      ),
      _SetupStepData(
        keyBase: 'battery',
        title: 'Battery optimization',
        description: 'Recommended for more reliable background runs.',
        complete: batteryOptimizationIgnored,
        actionLabel: 'Open settings',
        onOpen: onOpenBatteryOptimization,
        icon: Icons.battery_saver_outlined,
        recommended: true,
      ),
    ];
    final completedCount = steps.where((step) => step.complete).length;
    final coreReady =
        accessibilityEnabled &&
        overlayPermissionEnabled &&
        notificationsEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.stroke),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Guided setup', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$completedCount of ${steps.length} complete',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: coreReady
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh setup status',
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: completedCount / steps.length,
              backgroundColor: AppColors.surfaceSecondary,
              color: coreReady ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < steps.length; i++) ...[
            _SetupStepTile(step: steps[i], onRefresh: onRefresh),
            if (i != steps.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          _ReadyCheckBanner(
            coreReady: coreReady,
            batteryOptimizationIgnored: batteryOptimizationIgnored,
          ),
        ],
      ),
    );
  }
}

class _SetupStepTile extends StatelessWidget {
  const _SetupStepTile({required this.step, required this.onRefresh});

  final _SetupStepData step;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final statusColor = step.complete
        ? AppColors.success
        : step.recommended
        ? AppColors.warning
        : AppColors.primary;
    final statusLabel = step.complete
        ? 'Ready'
        : step.recommended
        ? 'Recommended'
        : 'Needs action';

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedActions = constraints.maxWidth < 560;
        final header = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(step.icon, color: statusColor, size: 19),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(step.title, style: AppTextStyles.titleMedium),
                      _StatusPill(label: statusLabel, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(step.description, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        );
        final actions = Wrap(
          alignment: useStackedActions
              ? WrapAlignment.start
              : WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              key: Key('setup-step-${step.keyBase}-open'),
              onPressed: step.complete ? null : step.onOpen,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(step.complete ? 'Already enabled' : step.actionLabel),
            ),
            TextButton.icon(
              key: Key('setup-step-${step.keyBase}-refresh'),
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: step.complete
                  ? AppColors.success.withValues(alpha: 0.34)
                  : AppColors.stroke,
            ),
          ),
          child: useStackedActions
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    const SizedBox(height: AppSpacing.sm),
                    actions,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: header),
                    const SizedBox(width: AppSpacing.md),
                    actions,
                  ],
                ),
        );
      },
    );
  }
}

class _ReadyCheckBanner extends StatelessWidget {
  const _ReadyCheckBanner({
    required this.coreReady,
    required this.batteryOptimizationIgnored,
  });

  final bool coreReady;
  final bool batteryOptimizationIgnored;

  @override
  Widget build(BuildContext context) {
    final color = coreReady ? AppColors.success : AppColors.primary;
    final title = coreReady
        ? 'Core automation is ready'
        : 'Required permissions are missing';
    final message = coreReady
        ? batteryOptimizationIgnored
              ? 'All setup steps are complete. You can configure targets and run safely.'
              : 'Battery optimization is still recommended.'
        : 'Complete required permissions before starting automation.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            coreReady ? Icons.verified_rounded : Icons.flag_outlined,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready check',
                  style: AppTextStyles.statusLabel.copyWith(color: color),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
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
        border: Border.all(color: color.withValues(alpha: 0.38)),
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

class _SetupStepData {
  const _SetupStepData({
    required this.keyBase,
    required this.title,
    required this.description,
    required this.complete,
    required this.actionLabel,
    required this.onOpen,
    required this.icon,
    this.recommended = false,
  });

  final String keyBase;
  final String title;
  final String description;
  final bool complete;
  final String actionLabel;
  final VoidCallback onOpen;
  final IconData icon;
  final bool recommended;
}
