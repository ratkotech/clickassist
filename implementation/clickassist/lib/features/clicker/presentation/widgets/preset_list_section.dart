import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_input_mode.dart';
import '../../domain/entities/clicker_preset.dart';

class PresetListSection extends StatelessWidget {
  const PresetListSection({
    super.key,
    required this.presets,
    required this.onSaveCurrent,
    required this.onImport,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ClickerPreset> presets;
  final VoidCallback onSaveCurrent;
  final VoidCallback onImport;
  final ValueChanged<ClickerPreset> onApply;
  final ValueChanged<ClickerPreset> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            if (presets.isNotEmpty)
              OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Import'),
              ),
            FilledButton.icon(
              onPressed: onSaveCurrent,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save Current'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (presets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: const Icon(
                    Icons.bookmarks_outlined,
                    color: AppColors.primaryBright,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('No presets yet', style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Save your current setup to reuse it instantly.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: onSaveCurrent,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Save Current'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onImport,
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Import Presets'),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          ...presets.map(
            (preset) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(preset.name, style: AppTextStyles.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${_presetTypeLabel(preset)} | ${preset.pointTimingMode.label} | ${preset.intervalMs} ms | ${preset.startDelayMs ~/ 1000}s delay',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => onApply(preset),
                      child: const Text('Load'),
                    ),
                    TextButton(
                      onPressed: () => onEdit(preset),
                      child: const Text('Edit'),
                    ),
                    IconButton(
                      onPressed: () => onDelete(preset.id),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _presetTypeLabel(ClickerPreset preset) {
    return preset.activeInputMode == ClickInputMode.manual
        ? 'Click Points Preset'
        : 'Mimic Preset';
  }
}
