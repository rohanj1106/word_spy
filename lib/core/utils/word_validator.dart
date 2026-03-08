/// Validates whether a word can be formed from a given set of letters.
/// Letters are case-insensitive; each letter in [letterSet] can only be used once.
class WordValidator {
  static bool canForm(String word, List<String> letterSet) {
    final available = List<String>.from(
      letterSet.map((l) => l.toUpperCase()),
    );

    for (final char in word.toUpperCase().split('')) {
      final idx = available.indexOf(char);
      if (idx == -1) return false;
      available.removeAt(idx);
    }
    return true;
  }

  static bool isRequired(String word, List<String> requiredWords) {
    return requiredWords
        .map((w) => w.toUpperCase())
        .contains(word.toUpperCase());
  }

  static bool isBonus(String word, List<String> bonusWords) {
    return bonusWords
        .map((w) => w.toUpperCase())
        .contains(word.toUpperCase());
  }
}
