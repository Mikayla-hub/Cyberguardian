class InputSanitizer {
  static String sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[<>"\x27;]'), '')
        .trim();
  }

  static String sanitizeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.hasScheme)) {
      return '';
    }
    if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
      return '';
    }
    return uri.toString();
  }

  static String sanitizeEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return '';
    }
    return email.trim().toLowerCase();
  }

  static bool isValidInput(String input, {int maxLength = 10000}) {
    if (input.isEmpty || input.length > maxLength) return false;
    if (RegExp(r'<script|javascript:|data:', caseSensitive: false).hasMatch(input)) {
      return false;
    }
    return true;
  }
}
