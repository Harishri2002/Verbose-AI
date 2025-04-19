class TextFormatter {
  static String formatCharCount(String text) {
    return '${text.length} characters';
  }

  static String formatWordCount(String text) {
    if (text.trim().isEmpty) return '0 words';
    return '${text.trim().split(RegExp(r'\s+')).length} words';
  }
}
