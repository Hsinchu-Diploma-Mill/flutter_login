class Regex {
  // https://stackoverflow.com/a/32686261/9449426
  static final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  // +886000000000
  static final phone = RegExp(r'^\+\d{12}$');
}
