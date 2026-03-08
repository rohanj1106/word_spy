import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/chapter.dart';
import '../../../core/models/player_progress.dart';
import '../../../core/services/chapter_service.dart';
import '../../../core/providers/player_progress_provider.dart';

class ChapterSelectState {
  final List<Chapter> chapters;
  final bool loading;

  const ChapterSelectState({
    this.chapters = const [],
    this.loading = true,
  });

  ChapterSelectState copyWith({List<Chapter>? chapters, bool? loading}) {
    return ChapterSelectState(
      chapters: chapters ?? this.chapters,
      loading: loading ?? this.loading,
    );
  }
}

class ChapterSelectNotifier extends StateNotifier<ChapterSelectState> {
  final Ref _ref;

  ChapterSelectNotifier(this._ref) : super(const ChapterSelectState()) {
    _load();
  }

  Future<void> _load() async {
    final chapters = await ChapterService.loadAll();
    state = state.copyWith(chapters: chapters, loading: false);
  }

  bool isLocked(Chapter chapter, PlayerProgress progress) {
    if (chapter.coinsToUnlock == 0) return false;
    return !progress.completedChapterIds.contains(chapter.id) &&
        progress.coins < chapter.coinsToUnlock;
  }

  bool isCompleted(Chapter chapter, PlayerProgress progress) {
    return progress.completedChapterIds.contains(chapter.id);
  }

  /// Returns 0–10 puzzles completed in this chapter.
  int puzzlesCompleted(Chapter chapter, PlayerProgress progress) {
    return progress.puzzlesCompletedInChapter(chapter.id);
  }

  /// Spends coins to unlock a chapter. Returns true on success.
  Future<bool> unlockChapter(Chapter chapter) async {
    return _ref
        .read(playerProgressProvider.notifier)
        .spendCoins(chapter.coinsToUnlock);
  }
}

final chapterSelectProvider =
    StateNotifierProvider<ChapterSelectNotifier, ChapterSelectState>(
  (ref) => ChapterSelectNotifier(ref),
);
