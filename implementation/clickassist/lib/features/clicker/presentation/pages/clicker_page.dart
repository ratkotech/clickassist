import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_input_mode.dart';
import '../../domain/entities/click_mode.dart';
import '../../domain/entities/click_point_timing_mode.dart';
import '../../domain/entities/click_step.dart';
import '../../domain/entities/clicker_preset.dart';
import '../providers/clicker_controller.dart';
import '../providers/clicker_state.dart';
import 'mimic_recorder_page.dart';
import '../widgets/click_mode_selector.dart';
import '../widgets/click_point_list.dart';
import '../widgets/clicker_dashboard_header.dart';
import '../widgets/clicker_interval_field.dart';
import '../widgets/clicker_section_card.dart';
import '../widgets/clicker_start_button.dart';
import '../widgets/health_check_tile.dart';
import '../widgets/input_mode_selector.dart';
import '../widgets/overlay_control_tile.dart';
import '../widgets/pattern_editor_section.dart';
import '../widgets/point_timing_mode_selector.dart';
import '../widgets/preset_list_section.dart';
import '../widgets/speed_preset_selector.dart';
import '../widgets/start_delay_selector.dart';
import '../widgets/tap_pattern_selector.dart';

class ClickerPage extends ConsumerStatefulWidget {
  const ClickerPage({super.key});

  @override
  ConsumerState<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends ConsumerState<ClickerPage> {
  late final TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    final interval = ref.read(
      clickerControllerProvider.select((state) => state.intervalMs),
    );
    _intervalController = TextEditingController(text: '$interval');

    Future.microtask(() {
      ref.read(clickerControllerProvider.notifier).refreshStatus();
    });
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _confirmClearPattern({
    required bool isMimicMode,
    required ClickerController controller,
  }) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isMimicMode ? 'Clear Mimic Pattern?' : 'Clear Targets?'),
          content: Text(
            isMimicMode
                ? 'This removes all recorded mimic taps and swipes and switches the run source back to manual.'
                : 'This removes all saved manual click points and pattern steps.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true && mounted) {
      controller.clearActivePattern();
    }
  }

  Future<void> _showPresetDialog(
    ClickerController controller, {
    ClickerPreset? preset,
  }) async {
    final textController = TextEditingController(text: preset?.name ?? '');
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(preset == null ? 'Save Preset' : 'Edit Preset'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Preset name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(preset == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true && mounted) {
      await controller.saveCurrentAsPreset(
        textController.text,
        presetId: preset?.id,
      );
    }
    textController.dispose();
  }

  Future<void> _confirmDeletePreset(
    ClickerController controller,
    ClickerPreset preset,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Preset?'),
          content: Text('Remove "${preset.name}" from saved presets?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      await controller.deletePreset(preset.id);
    }
  }

  Future<void> _showImportPresetsDialog(
    ClickerController controller,
  ) async {
    final textController = TextEditingController();
    String? errorText;

    final submittedJson = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Import Presets'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      minLines: 8,
                      maxLines: 14,
                      decoration: InputDecoration(
                        hintText: 'Paste your preset JSON here...',
                        errorText: errorText,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (textController.text.trim().isEmpty) {
                      setState(() {
                        errorText = 'Invalid preset format';
                      });
                      return;
                    }
                    Navigator.of(context).pop(textController.text.trim());
                  },
                  child: const Text('Import'),
                ),
              ],
            );
          },
        );
      },
    );

    textController.dispose();

    if (submittedJson == null || !mounted) {
      return;
    }

    final replaceExisting = await _showImportModeDialog();
    if (replaceExisting == null || !mounted) {
      return;
    }

    try {
      await controller.importPresetsJson(
        submittedJson,
        replaceExisting: replaceExisting,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Presets imported successfully')),
      );
    } on FormatException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid preset format')),
      );
    }
  }

  Future<bool?> _showImportModeDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import Mode'),
          content: const Text(
            'Replace existing presets or add to them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Merge'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDisclosure({
    required String title,
    required String description,
    required String continueLabel,
    required Future<void> Function() onContinue,
  }) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(continueLabel),
            ),
          ],
        );
      },
    );

    if (approved == true && mounted) {
      await onContinue();
    }
  }

  Future<void> _handleAccessibilityPermission(
    ClickerController controller,
  ) async {
    await _showPermissionDisclosure(
      title: 'Accessibility service disclosure',
      description:
          'This feature requires AccessibilityService to simulate taps and swipes you configure. ClickAssist does not enable this automatically. If you continue, Android Accessibility settings will open so you can decide.',
      continueLabel: 'Open settings',
      onContinue: controller.openAccessibilitySettings,
    );
  }

  Future<void> _handleOverlayPermission(ClickerController controller) async {
    await _showPermissionDisclosure(
      title: 'Overlay permission disclosure',
      description:
          'This app uses overlay permission to show floating controls above other apps and to help you place targets on screen. If you continue, Android overlay settings will open so you can choose whether to allow it.',
      continueLabel: 'Open settings',
      onContinue: controller.openOverlaySettings,
    );
  }

  Future<void> _handleBatteryDisclosure(ClickerController controller) async {
    await _showPermissionDisclosure(
      title: 'Battery optimization disclosure',
      description:
          'Disabling battery optimization is optional. It can improve background reliability, but you can keep Android battery optimization enabled if you prefer.',
      continueLabel: 'Open settings',
      onContinue: controller.openBatteryOptimizationSettings,
    );
  }

  Future<void> _handleNotificationDisclosure(
    ClickerController controller,
  ) async {
    await _showPermissionDisclosure(
      title: 'Notification disclosure',
      description:
          'ClickAssist uses notifications for foreground status and quick native controls while background services are active. If you continue, Android will request or open notification settings.',
      continueLabel: 'Continue',
      onContinue: controller.openNotificationSettings,
    );
  }

  Future<void> _handleOverlayToggle(
    ClickerController controller,
    bool accessibilityEnabled,
    bool overlayPermissionEnabled,
  ) async {
    if (!accessibilityEnabled) {
      await _handleAccessibilityPermission(controller);
      return;
    }
    if (!overlayPermissionEnabled) {
      await _handleOverlayPermission(controller);
      return;
    }
    await controller.toggleOverlay();
  }

  Future<void> _handlePointCapture(
    ClickerController controller,
    bool overlayPermissionEnabled, {
    String? editPointId,
  }) async {
    if (!overlayPermissionEnabled) {
      await _handleOverlayPermission(controller);
      return;
    }
    await controller.startPointCapture(editPointId: editPointId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clickerControllerProvider);
    final controller = ref.read(clickerControllerProvider.notifier);
    final isMimicMode = state.activeInputMode == ClickInputMode.mimic;

    final intervalText = '${state.intervalMs}';
    if (_intervalController.text != intervalText) {
      _intervalController.value = _intervalController.value.copyWith(
        text: intervalText,
        selection: TextSelection.collapsed(offset: intervalText.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth = constraints.maxWidth >= 1080 ? 920.0 : 720.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.pageTop,
                AppSpacing.pageHorizontal,
                AppSpacing.xxxl,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClickerDashboardHeader(
                        actionsPerSecond:
                            state.isRunning ? state.actionsPerSecond : 0,
                        clicks: state.totalClicks,
                        totalClicks: state.totalClicks,
                        onRefresh: controller.refreshStatus,
                        onOpenHelp: () {
                          Navigator.of(context).pushNamed(AppRouter.helpSafety);
                        },
                        onOpenSettings: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.settingsLegal,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _StatusBanner(
                        message: state.statusMessage,
                        isAlert:
                            !state.accessibilityEnabled ||
                            !state.overlayPermissionEnabled ||
                            state.safetyWarning != null,
                        actionLabel:
                            !state.accessibilityEnabled ? 'Enable' : 'Overlay',
                        onOpenSettings: !state.accessibilityEnabled
                            ? () {
                                _handleAccessibilityPermission(controller);
                              }
                            : () {
                                _handleOverlayToggle(
                                  controller,
                                  state.accessibilityEnabled,
                                  state.overlayPermissionEnabled,
                                );
                              },
                      ),
                      if (state.safetyWarning != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          state.safetyWarning!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerStartButton(
                        isRunning: state.isRunning,
                        isAccessibilityEnabled: state.accessibilityEnabled,
                        onPressed: controller.toggleRunning,
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Run Source',
                        icon: Icons.swap_horiz_rounded,
                        child: InputModeSelector(
                          selectedMode: state.activeInputMode,
                          manualStepCount: state.manualClickSteps.length,
                          mimicStepCount: state.mimicClickSteps.length,
                          onSelected: controller.setInputMode,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Tap Pattern',
                        icon: Icons.touch_app_rounded,
                        child: TapPatternSelector(
                          selectedPattern: state.selectedPattern,
                          onSelected: controller.setPattern,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Click Mode',
                        icon: Icons.repeat_rounded,
                        initiallyExpanded: false,
                        child: ClickModeSelector(
                          clickMode: state.clickMode,
                          targetCycles: state.targetCycles,
                          onModeChanged: controller.setClickMode,
                          onTargetCyclesChanged: controller.setTargetCycles,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Click Speed',
                        icon: Icons.bolt_rounded,
                        child: Column(
                          children: [
                            SpeedPresetSelector(
                              selectedPreset: state.speedPreset,
                              intervalMs: state.intervalMs,
                              onPresetSelected: controller.selectSpeedPreset,
                              onStepInterval: controller.stepInterval,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            ClickerIntervalField(
                              controller: _intervalController,
                              onChanged: controller.updateInterval,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Start Delay',
                        icon: Icons.timer_outlined,
                        initiallyExpanded: false,
                        child: StartDelaySelector(
                          startDelayMs:
                              state.startDelayEnabled ? state.startDelayMs : 0,
                          onPresetSelected: controller.setStartDelayMs,
                          onCustomChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null) {
                              controller.setStartDelayMs(parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Visual Feedback',
                        icon: Icons.visibility_rounded,
                        initiallyExpanded: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.showGestureIndicator
                                    ? 'Gesture indicators are active during playback.'
                                    : 'Playback stays visually clean with indicators hidden.',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Switch(
                              value: state.showGestureIndicator,
                              onChanged: controller.toggleGestureIndicator,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      if (state.activeInputMode == ClickInputMode.manual) ...[
                        ClickerSectionCard(
                          title: 'Click Points',
                          icon: Icons.my_location_rounded,
                          child: Column(
                            children: [
                              ClickPointList(
                                clickPoints: state.manualClickPoints,
                                onRemove: controller.removeClickPoint,
                                onAdd: () {
                                  _handlePointCapture(
                                    controller,
                                    state.overlayPermissionEnabled,
                                  );
                                },
                                onEdit: (id) {
                                  _handlePointCapture(
                                    controller,
                                    state.overlayPermissionEnabled,
                                    editPointId: id,
                                  );
                                },
                                multiClickEnabled: state.isMultiClickEnabled,
                                onMultiClickChanged: controller.toggleMultiClick,
                                pointPickerActive: state.pointPickerActive,
                                onCancelPicker: controller.cancelPointCapture,
                              ),
                              PointTimingModeSelector(
                                selectedMode: state.pointTimingMode,
                                enabled:
                                    state.isMultiClickEnabled &&
                                    state.manualClickSteps.length > 1,
                                onSelected: controller.setPointTimingMode,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                      ],
                      if (isMimicMode) ...[
                        ClickerSectionCard(
                          title: 'Mimic Editor',
                          icon: Icons.gesture_rounded,
                          child: PatternEditorSection(
                            isMimicMode: true,
                            clickPoints: state.mimicClickPoints,
                            clickSteps: state.mimicClickSteps,
                            onAddStep: controller.addPatternStep,
                            onRecordMimic: () async {
                              final result = await Navigator.of(context)
                                  .push<MimicRecorderResult>(
                                    MaterialPageRoute(
                                      builder: (_) => const MimicRecorderPage(),
                                    ),
                                  );
                              if (result == null || !context.mounted) {
                                return;
                              }
                              controller.importRecordedPattern(
                                clickPoints: result.clickPoints,
                                clickSteps: result.clickSteps,
                              );
                            },
                            onClearSteps: () => _confirmClearPattern(
                              isMimicMode: true,
                              controller: controller,
                            ),
                            onRemoveStep: controller.removePatternStep,
                            onActionTypeChanged:
                                controller.updatePatternStepActionType,
                            onPointChanged: controller.updatePatternStepPoint,
                            onEndPointChanged:
                                controller.updatePatternStepEndPoint,
                            onDelayChanged: controller.updatePatternStepDelay,
                            onDurationChanged:
                                controller.updatePatternStepDuration,
                            onMoveStepUp: (stepId) =>
                                controller.movePatternStep(stepId, -1),
                            onMoveStepDown: (stepId) =>
                                controller.movePatternStep(stepId, 1),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                      ],
                      ClickerSectionCard(
                        title: 'Presets',
                        icon: Icons.bookmarks_outlined,
                        initiallyExpanded: false,
                        child: PresetListSection(
                          presets: state.presets,
                          onSaveCurrent: () => _showPresetDialog(controller),
                          onImport: () => _showImportPresetsDialog(controller),
                          onApply: controller.applyPreset,
                          onEdit: (preset) =>
                              _showPresetDialog(controller, preset: preset),
                          onDelete: (id) {
                            final preset = state.presets.firstWhere(
                              (entry) => entry.id == id,
                            );
                            _confirmDeletePreset(controller, preset);
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Floating Overlay',
                        icon: Icons.picture_in_picture_alt_rounded,
                        initiallyExpanded: false,
                        child: OverlayControlTile(
                          accessibilityEnabled: state.accessibilityEnabled,
                          overlayPermissionEnabled: state.overlayPermissionEnabled,
                          overlayEnabled: state.overlayEnabled,
                          overlayVisible: state.overlayVisible,
                          onPressed: () {
                            _handleOverlayToggle(
                              controller,
                              state.accessibilityEnabled,
                              state.overlayPermissionEnabled,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Help & Safety',
                        icon: Icons.help_outline_rounded,
                        initiallyExpanded: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review setup guidance, permissions, privacy, and responsible-use notes before enabling sensitive features.',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRouter.helpSafety);
                                  },
                                  icon: const Icon(Icons.menu_book_rounded),
                                  label: const Text('Open Help & Safety'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRouter.settingsLegal);
                                  },
                                  icon: const Icon(Icons.tune_rounded),
                                  label: const Text('Settings & Legal'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ClickerSectionCard(
                        title: 'Setup Health',
                        icon: Icons.health_and_safety_outlined,
                        initiallyExpanded: false,
                        child: Column(
                          children: [
                            HealthCheckTile(
                              title: 'Accessibility service',
                              description: state.accessibilityServiceConnected
                                  ? 'Connected and ready for gesture dispatch.'
                                  : 'Required for background taps in other apps.',
                              isHealthy:
                                  state.accessibilityEnabled &&
                                  state.accessibilityServiceConnected,
                              actionLabel: 'Enable',
                              onAction: () {
                                _handleAccessibilityPermission(controller);
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HealthCheckTile(
                              title: 'Display over other apps',
                              description: state.overlayPermissionEnabled
                                  ? 'Overlay controls and point picker are available.'
                                  : 'Needed for floating controls and target picking.',
                              isHealthy: state.overlayPermissionEnabled,
                              actionLabel: 'Grant',
                              onAction: () {
                                _handleOverlayPermission(controller);
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HealthCheckTile(
                              title: 'Battery optimization',
                              description: state.batteryOptimizationIgnored
                                  ? 'Background services are less likely to be stopped.'
                                  : 'Disable optimization to improve reliability.',
                              isHealthy: state.batteryOptimizationIgnored,
                              actionLabel: 'Open',
                              onAction: () {
                                _handleBatteryDisclosure(controller);
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HealthCheckTile(
                              title: 'Device temperature',
                              description: _thermalDescription(
                                state.thermalStatus,
                              ),
                              isHealthy: state.thermalStatus < 3,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HealthCheckTile(
                              title: 'Battery level',
                              description: _batteryDescription(
                                state.batteryLevelPercent,
                                state.batteryCharging,
                              ),
                              isHealthy:
                                  state.batteryLevelPercent < 0 ||
                                  state.batteryLevelPercent >= 20 ||
                                  state.batteryCharging,
                              actionLabel: 'Refresh',
                              onAction: controller.refreshStatus,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HealthCheckTile(
                              title: 'Run intensity',
                              description: _runIntensityDescription(state),
                              isHealthy: _isRunIntensityHealthy(state),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HealthCheckTile(
                              title: 'Notifications',
                              description: state.notificationsEnabled
                                  ? 'Native quick controls can stay visible.'
                                  : 'Enable notifications for better native controls.',
                              isHealthy: state.notificationsEnabled,
                              actionLabel: 'Open',
                              onAction: () {
                                _handleNotificationDisclosure(controller);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Text(
                        state.clickMode == ClickMode.count
                            ? 'Count mode stops after ${state.targetCycles} cycles using ${state.activeInputMode.title.toLowerCase()}.'
                            : 'Infinite mode keeps running ${state.activeInputMode.title.toLowerCase()} until you press STOP.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _thermalDescription(int thermalStatus) {
    if (thermalStatus >= 4) {
      return 'High temperature detected. Automation is blocked until the device cools.';
    }
    if (thermalStatus >= 3) {
      return 'Elevated temperature. Use slower intervals or pause if the phone feels warm.';
    }
    return 'Temperature is normal for automation.';
  }

  String _batteryDescription(int batteryLevelPercent, bool batteryCharging) {
    if (batteryLevelPercent < 0) {
      return 'Battery status is not available on this device.';
    }
    final suffix = batteryCharging ? ' and charging' : '';
    if (batteryLevelPercent < 10 && !batteryCharging) {
      return 'Battery is $batteryLevelPercent%$suffix. Charge before running automation.';
    }
    if (batteryLevelPercent < 20 && !batteryCharging) {
      return 'Battery is $batteryLevelPercent%$suffix. Long runs may drain it quickly.';
    }
    return 'Battery is $batteryLevelPercent%$suffix.';
  }

  String _runIntensityDescription(ClickerState state) {
    final swipeCount = state.activeClickSteps
        .where((step) => step.actionType == ClickStepActionType.swipe)
        .length;
    if (state.intervalMs < 20) {
      return 'Ultra-fast interval. Best for short tests only.';
    }
    if (swipeCount > 0 && state.intervalMs < 50) {
      return 'Swipe route is very fast. 50 ms or higher is safer.';
    }
    if (state.isMultiClickEnabled &&
        state.pointTimingMode == ClickPointTimingMode.simultaneous &&
        swipeCount > 2) {
      return 'Multiple simultaneous swipes may be heavy on some devices.';
    }
    return 'Current speed and route complexity look reasonable.';
  }

  bool _isRunIntensityHealthy(ClickerState state) {
    final swipeCount = state.activeClickSteps
        .where((step) => step.actionType == ClickStepActionType.swipe)
        .length;
    return state.intervalMs >= 20 &&
        (swipeCount == 0 || state.intervalMs >= 50) &&
        !(state.isMultiClickEnabled &&
            state.pointTimingMode == ClickPointTimingMode.simultaneous &&
            swipeCount > 2);
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.isAlert,
    required this.actionLabel,
    required this.onOpenSettings,
  });

  final String message;
  final bool isAlert;
  final String actionLabel;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.primaryMuted : const Color(0xFF0D2A44),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isAlert ? AppColors.primary : AppColors.stroke,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAlert ? Icons.info_outline_rounded : Icons.check_circle_outline,
            color: isAlert ? AppColors.primary : AppColors.primaryBright,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryBright,
              ),
            ),
          ),
          if (isAlert)
            TextButton(onPressed: onOpenSettings, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
