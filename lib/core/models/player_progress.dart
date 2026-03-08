class PlayerProgress {
  final int coins;
  final Set<String> completedPuzzleIds;   // e.g. "london_01"
  final Set<String> completedChapterIds;  // e.g. "london"
  final Set<String> earnedStamps;         // chapter IDs with stamp awarded

  const PlayerProgress({
    this.coins = 50,
    this.completedPuzzleIds = const {},
    this.completedChapterIds = const {},
    this.earnedStamps = const {},
  });

  PlayerProgress copyWith({
    int? coins,
    Set<String>? completedPuzzleIds,
    Set<String>? completedChapterIds,
    Set<String>? earnedStamps,
  }) {
    return PlayerProgress(
      coins: coins ?? this.coins,
      completedPuzzleIds: completedPuzzleIds ?? this.completedPuzzleIds,
      completedChapterIds: completedChapterIds ?? this.completedChapterIds,
      earnedStamps: earnedStamps ?? this.earnedStamps,
    );
  }

  int puzzlesCompletedInChapter(String chapterId) {
    return completedPuzzleIds
        .where((id) => id.startsWith('${chapterId}_'))
        .length;
  }
}
