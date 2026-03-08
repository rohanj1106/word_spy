import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';

/// Persists Word Spy player progress in SharedPreferences.
/// Keys are prefixed with "ws_" to avoid collision with any legacy data.
class ProgressService {
  static const _keyCoins             = 'ws_coins';
  static const _keyCompletedPuzzles  = 'ws_completed_puzzles';
  static const _keyCompletedChapters = 'ws_completed_chapters';
  static const _keyEarnedStamps      = 'ws_earned_stamps';

  // Accessibility (shared with settings)
  static const _keyFontPreference = 'font_preference';
  static const _keyTextScale      = 'text_size_scale';
  static const _keyHighContrast   = 'high_contrast';

  Future<PlayerProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PlayerProgress(
      coins: prefs.getInt(_keyCoins) ?? 50,
      completedPuzzleIds:
          Set<String>.from(prefs.getStringList(_keyCompletedPuzzles) ?? []),
      completedChapterIds:
          Set<String>.from(prefs.getStringList(_keyCompletedChapters) ?? []),
      earnedStamps:
          Set<String>.from(prefs.getStringList(_keyEarnedStamps) ?? []),
    );
  }

  Future<void> save(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_keyCoins, progress.coins),
      prefs.setStringList(
          _keyCompletedPuzzles, progress.completedPuzzleIds.toList()),
      prefs.setStringList(
          _keyCompletedChapters, progress.completedChapterIds.toList()),
      prefs.setStringList(_keyEarnedStamps, progress.earnedStamps.toList()),
    ]);
  }

  Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCoins) ?? 50;
    await prefs.setInt(_keyCoins, current + amount);
  }

  /// Returns false if the player doesn't have enough coins.
  Future<bool> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCoins) ?? 0;
    if (current < amount) return false;
    await prefs.setInt(_keyCoins, current - amount);
    return true;
  }

  Future<void> markPuzzleComplete(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedPuzzles) ?? [];
    if (!list.contains(puzzleId)) {
      list.add(puzzleId);
      await prefs.setStringList(_keyCompletedPuzzles, list);
    }
  }

  Future<void> markChapterComplete(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final chapters = prefs.getStringList(_keyCompletedChapters) ?? [];
    final stamps = prefs.getStringList(_keyEarnedStamps) ?? [];
    if (!chapters.contains(chapterId)) {
      chapters.add(chapterId);
      stamps.add(chapterId);
      await Future.wait([
        prefs.setStringList(_keyCompletedChapters, chapters),
        prefs.setStringList(_keyEarnedStamps, stamps),
      ]);
    }
  }

  // Accessibility settings
  Future<String> getFontPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFontPreference) ?? 'poppins';
  }

  Future<void> setFontPreference(String font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontPreference, font);
  }

  Future<double> getTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTextScale) ?? 1.0;
  }

  Future<void> setTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextScale, scale);
  }

  Future<bool> getHighContrast() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHighContrast) ?? false;
  }

  Future<void> setHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHighContrast, enabled);
  }
}
