enum ClickInputMode {
  manual('manual', 'Click Points'),
  mimic('mimic', 'Mimic Pattern');

  const ClickInputMode(this.value, this.title);

  final String value;
  final String title;
}
