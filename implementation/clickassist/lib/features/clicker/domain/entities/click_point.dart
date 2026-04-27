class ClickPoint {
  const ClickPoint({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.xPercent,
    required this.yPercent,
  });

  final String id;
  final String label;
  final double x;
  final double y;
  final double xPercent;
  final double yPercent;

  ClickPoint copyWith({
    String? id,
    String? label,
    double? x,
    double? y,
    double? xPercent,
    double? yPercent,
  }) {
    return ClickPoint(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      xPercent: xPercent ?? this.xPercent,
      yPercent: yPercent ?? this.yPercent,
    );
  }
}
