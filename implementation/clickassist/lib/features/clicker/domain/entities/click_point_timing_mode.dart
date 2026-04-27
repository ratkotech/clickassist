enum ClickPointTimingMode {
  sequential('sequential', 'Sequential'),
  simultaneous('simultaneous', 'Simultaneous');

  const ClickPointTimingMode(this.value, this.label);

  final String value;
  final String label;
}
