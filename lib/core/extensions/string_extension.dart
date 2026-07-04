extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Returns the original string if it is empty.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of every word.
  ///
  /// Words are split by whitespace.
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.capitalize)
        .join(' ');
  }

  /// Returns `true` if the string is a valid email address.
  bool get isValidEmail {
    if (isEmpty) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trim());
  }

  /// Returns `true` if the string is a valid 10-digit Indian phone number.
  ///
  /// Accepts an optional leading `+91` or `0` prefix.
  bool get isValidPhone {
    if (isEmpty) return false;
    return RegExp(r'^(?:\+91|0)?[6-9]\d{9}$').hasMatch(trim());
  }

  /// Returns `true` if the string has at least 6 characters
  /// (minimum password requirement).
  bool get isValidPassword => length >= 6;

  /// Returns `true` if the string is a valid name:
  /// at least 2 characters, letters and spaces only.
  bool get isValidName {
    if (trim().length < 2) return false;
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(trim());
  }

  /// Returns the initials formed from the first letter of the first
  /// two words, uppercased.
  ///
  /// For a single word the first letter is returned.
  /// For an empty string an empty string is returned.
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  /// Truncates the string to [maxLength] characters and appends an
  /// ellipsis (`…`) if it exceeds that length.
  ///
  /// If [maxLength] is greater than or equal to the string length the
  /// original string is returned unchanged.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }
}

/// Null-safe string helper available on `String?`.
extension NullableStringExtension on String? {
  /// Returns `true` when the string is neither `null` nor empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
