import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/click_point.dart';
import '../../domain/entities/click_step.dart';

class MimicRecorderResult {
  const MimicRecorderResult({
    required this.clickPoints,
    required this.clickSteps,
  });

  final List<ClickPoint> clickPoints;
  final List<ClickStep> clickSteps;
}

class MimicRecorderPage extends StatefulWidget {
  const MimicRecorderPage({super.key});

  @override
  State<MimicRecorderPage> createState() => _MimicRecorderPageState();
}

class _MimicRecorderPageState extends State<MimicRecorderPage> {
  final List<_RecordedGesture> _gestures = [];
  Offset? _pointerDown;
  Offset? _currentPointer;
  DateTime? _pointerDownAt;
  int _recordingSeed = DateTime.now().microsecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mimic Recorder'),
        actions: [
          TextButton(
            onPressed: _gestures.isEmpty ? null : _finishRecording,
            child: const Text('Import'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perform taps and swipes naturally on the pad below. We will classify them and import them into the pattern editor.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _InfoBadge(
                  icon: Icons.touch_app_outlined,
                  label: '$_tapCount taps',
                ),
                _InfoBadge(
                  icon: Icons.swipe_outlined,
                  label: '$_swipeCount swipes',
                ),
                const _InfoBadge(
                  icon: Icons.rule_rounded,
                  label: 'Swipe threshold 28px',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Listener(
                      onPointerDown: (event) {
                        setState(() {
                          _pointerDown = event.localPosition;
                          _currentPointer = event.localPosition;
                          _pointerDownAt = DateTime.now();
                        });
                      },
                      onPointerMove: (event) {
                        setState(() {
                          _currentPointer = event.localPosition;
                        });
                      },
                      onPointerUp: (event) {
                        _recordGesture(
                          size: constraints.biggest,
                          end: event.localPosition,
                        );
                      },
                      child: CustomPaint(
                        painter: _MimicRecorderPainter(
                          gestures: _gestures,
                          draftStart: _pointerDown,
                          draftEnd: _currentPointer,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_gestures.length} gesture${_gestures.length == 1 ? '' : 's'} recorded',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                OutlinedButton(
                  onPressed: _gestures.isEmpty
                      ? null
                      : () => setState(() => _gestures.removeLast()),
                  child: const Text('Undo'),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton(
                  onPressed: _gestures.isEmpty
                      ? null
                      : () => setState(_gestures.clear),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _recordGesture({required Size size, required Offset end}) {
    final start = _pointerDown;
    final startedAt = _pointerDownAt;
    _pointerDown = null;
    _currentPointer = null;
    _pointerDownAt = null;

    if (start == null || startedAt == null) {
      return;
    }

    final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
    final distance = (end - start).distance;
    final isSwipe = distance > 28;

    setState(() {
      _gestures.add(
        _RecordedGesture(
          actionType: isSwipe
              ? ClickStepActionType.swipe
              : ClickStepActionType.tap,
          start: start,
          end: end,
          delayMs: 500,
          durationMs: math.max(
            24,
            math.min(1200, durationMs == 0 ? 24 : durationMs),
          ),
          size: size,
        ),
      );
    });
  }

  void _finishRecording() {
    final points = <ClickPoint>[];
    final steps = <ClickStep>[];
    final seed = _recordingSeed;
    _recordingSeed += 1;

    String addPoint(Offset offset, Size size, String labelPrefix) {
      final id = 'recorded-point-$seed-${points.length + 1}';
      final point = ClickPoint(
        id: id,
        label: '$labelPrefix ${points.length + 1}',
        x: offset.dx,
        y: offset.dy,
        xPercent: (offset.dx / size.width).clamp(0.0, 1.0),
        yPercent: (offset.dy / size.height).clamp(0.0, 1.0),
      );
      points.add(point);
      return id;
    }

    for (var i = 0; i < _gestures.length; i++) {
      final gesture = _gestures[i];
      final startPointId = addPoint(
        gesture.start,
        gesture.size,
        'Recorded Point',
      );
      String? endPointId;
      if (gesture.actionType == ClickStepActionType.swipe) {
        endPointId = addPoint(gesture.end, gesture.size, 'Recorded Point');
      }

      steps.add(
        ClickStep(
          id: 'recorded-step-$seed-${i + 1}',
          pointId: startPointId,
          label: 'Recorded Step ${i + 1}',
          actionType: gesture.actionType,
          endPointId: endPointId,
          delayMs: gesture.delayMs,
          pressDurationMs: gesture.durationMs,
        ),
      );
    }

    Navigator.of(
      context,
    ).pop(MimicRecorderResult(clickPoints: points, clickSteps: steps));
  }

  int get _tapCount => _gestures
      .where((gesture) => gesture.actionType == ClickStepActionType.tap)
      .length;

  int get _swipeCount => _gestures
      .where((gesture) => gesture.actionType == ClickStepActionType.swipe)
      .length;
}

class _RecordedGesture {
  const _RecordedGesture({
    required this.actionType,
    required this.start,
    required this.end,
    required this.delayMs,
    required this.durationMs,
    required this.size,
  });

  final ClickStepActionType actionType;
  final Offset start;
  final Offset end;
  final int delayMs;
  final int durationMs;
  final Size size;
}

class _MimicRecorderPainter extends CustomPainter {
  const _MimicRecorderPainter({
    required this.gestures,
    required this.draftStart,
    required this.draftEnd,
  });

  final List<_RecordedGesture> gestures;
  final Offset? draftStart;
  final Offset? draftEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.stroke.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final dx = size.width * i / 4;
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    for (final gesture in gestures) {
      _paintGesture(canvas, gesture.start, gesture.end, gesture.actionType);
    }
    if (draftStart != null && draftEnd != null) {
      _paintGesture(
        canvas,
        draftStart!,
        draftEnd!,
        _gestureType(draftStart!, draftEnd!),
      );
    }
  }

  ClickStepActionType _gestureType(Offset start, Offset end) {
    return (end - start).distance > 28
        ? ClickStepActionType.swipe
        : ClickStepActionType.tap;
  }

  void _paintGesture(
    Canvas canvas,
    Offset start,
    Offset end,
    ClickStepActionType type,
  ) {
    final accent = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = AppColors.primaryBright;

    canvas.drawCircle(start, 8, dot);
    if (type == ClickStepActionType.swipe) {
      canvas.drawLine(start, end, accent);
      canvas.drawCircle(end, 6, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _MimicRecorderPainter oldDelegate) {
    return oldDelegate.gestures != gestures ||
        oldDelegate.draftStart != draftStart ||
        oldDelegate.draftEnd != draftEnd;
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
