import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chapter.dart';
import '../models/puzzle.dart';

class ChapterService {
  static List<Chapter>? _cache;

  static Future<List<Chapter>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/chapters/chapters.json');
    _cache = (jsonDecode(raw) as List)
        .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  static Future<Chapter?> getById(String id) async {
    final all = await loadAll();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<Puzzle?> getPuzzle(String chapterId, int number) async {
    final chapter = await getById(chapterId);
    if (chapter == null) return null;
    try {
      return chapter.puzzles.firstWhere((p) => p.number == number);
    } catch (_) {
      return null;
    }
  }

  /// Clears cache — useful in tests.
  static void clearCache() => _cache = null;
}
