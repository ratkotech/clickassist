import 'package:flutter/material.dart';

enum TapPattern {
  single(
    value: 'single',
    title: 'Single',
    subtitle: 'One tap each interval',
    icon: Icons.panorama_fish_eye_rounded,
    tapsPerCycle: 1,
  ),
  double(
    value: 'double',
    title: 'Double',
    subtitle: 'Two quick taps',
    icon: Icons.copy_all_rounded,
    tapsPerCycle: 2,
  ),
  triple(
    value: 'triple',
    title: 'Triple',
    subtitle: 'Three quick taps',
    icon: Icons.layers_rounded,
    tapsPerCycle: 3,
  ),
  burst(
    value: 'burst',
    title: 'Burst',
    subtitle: '5 rapid then pause',
    icon: Icons.bolt_rounded,
    tapsPerCycle: 5,
  ),
  wave(
    value: 'wave',
    title: 'Wave',
    subtitle: 'Accelerating rhythm',
    icon: Icons.show_chart_rounded,
    tapsPerCycle: 4,
  ),
  heart(
    value: 'heart',
    title: 'Heart',
    subtitle: 'Pulse rhythm',
    icon: Icons.favorite_border_rounded,
    tapsPerCycle: 2,
  );

  const TapPattern({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tapsPerCycle,
  });

  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final int tapsPerCycle;
}
