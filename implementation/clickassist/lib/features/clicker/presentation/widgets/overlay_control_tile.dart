import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class OverlayControlTile extends StatelessWidget {
  const OverlayControlTile({
    super.key,
    required this.accessibilityEnabled,
    required this.overlayPermissionEnabled,
    required this.overlayEnabled,
    required this.overlayVisible,
    required this.onPressed,
  });

  final bool accessibilityEnabled;
  final bool overlayPermissionEnabled;
  final bool overlayEnabled;
  final bool overlayVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final title = overlayVisible
        ? 'Floating Overlay Active'
        : overlayEnabled
        ? 'Floating Overlay Ready'
        : 'Floating Overlay';
    final description = !accessibilityEnabled
        ? 'Enable ClickAssist in Accessibility to use overlay controls.'
        : !overlayPermissionEnabled
        ? 'Allow display over other apps so the overlay can stay available across apps.'
        : overlayEnabled
        ? 'Overlay is ready. Use it to start automation from any screen.'
        : 'Keep a compact control bar available on top of other apps.'
        ;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: overlayVisible
                  ? AppColors.primary
                  : overlayEnabled
                  ? AppColors.primaryBright.withValues(alpha: 0.72)
                  : AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              overlayVisible
                  ? Icons.layers_clear_rounded
                  : overlayEnabled
                  ? Icons.picture_in_picture_alt_rounded
                  : Icons.picture_in_picture_alt_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            onPressed: onPressed,
            child: Text(
              accessibilityEnabled && overlayPermissionEnabled
                  ? (overlayEnabled ? 'Disable' : 'Enable')
                  : !accessibilityEnabled
                  ? 'Enable'
                  : 'Grant',
            ),
          ),
        ],
      ),
    );
  }
}
