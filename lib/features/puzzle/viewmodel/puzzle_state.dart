import '../../../core/models/puzzle.dart';
import '../../../core/models/word_placement.dart';

class PuzzleState {
  final Puzzle? puzzle;
  final bool loading;

  /// Cells currently selected by the player (row, col).
  final List<(int, int)> selectedCells;

  /// Words that have been found (by word string).
  final Set<String> foundWords;

  /// The last word found — used to trigger success animation.
  final String? lastFoundWord;

  /// Coins earned for the last found word (10 required, 25 bonus).
  final int? coinsEarned;

  final bool puzzleComplete;

  /// Cells revealed by hints — shown highlighted in gold.
  final Set<(int, int)> hintedCells;

  const PuzzleState({
    this.puzzle,
    this.loading = true,
    this.selectedCells = const [],
    this.foundWords = const {},
    this.lastFoundWord,
    this.coinsEarned,
    this.puzzleComplete = false,
    this.hintedCells = const {},
  });

  PuzzleState copyWith({
    Puzzle? puzzle,
    bool? loading,
    List<(int, int)>? selectedCells,
    Set<String>? foundWords,
    String? lastFoundWord,
    int? coinsEarned,
    bool? puzzleComplete,
    Set<(int, int)>? hintedCells,
    bool clearLastFound = false,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      loading: loading ?? this.loading,
      selectedCells: selectedCells ?? this.selectedCells,
      foundWords: foundWords ?? this.foundWords,
      lastFoundWord: clearLastFound ? null : (lastFoundWord ?? this.lastFoundWord),
      coinsEarned: clearLastFound ? null : (coinsEarned ?? this.coinsEarned),
      puzzleComplete: puzzleComplete ?? this.puzzleComplete,
      hintedCells: hintedCells ?? this.hintedCells,
    );
  }

  bool isCellSelected(int row, int col) =>
      selectedCells.contains((row, col));

  bool isCellFound(int row, int col, List<WordPlacement> words) {
    return words
        .where((w) => foundWords.contains(w.word.word))
        .any((w) => w.cells.contains((row, col)));
  }
}
