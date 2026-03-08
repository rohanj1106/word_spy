import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/hint.dart';
import '../../../core/services/chapter_service.dart';
import '../../../core/providers/player_progress_provider.dart';
import 'puzzle_state.dart';

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  final String _chapterId;
  final int _puzzleNumber;
  final Ref _ref;

  PuzzleNotifier(this._chapterId, this._puzzleNumber, this._ref)
      : super(const PuzzleState()) {
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final puzzle = await ChapterService.getPuzzle(_chapterId, _puzzleNumber);
    state = state.copyWith(puzzle: puzzle, loading: false);
  }

  // ── Selection ────────────────────────────────────────────────

  void selectCell(int row, int col) {
    if (state.selectedCells.contains((row, col))) return;
    state = state.copyWith(
      selectedCells: [...state.selectedCells, (row, col)],
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedCells: []);
  }

  // ── Submission ───────────────────────────────────────────────

  /// Called when the player lifts their finger.
  /// Returns coins earned, or null if no match.
  int? submitSelection() {
    final puzzle = state.puzzle;
    if (puzzle == null || state.selectedCells.isEmpty) return null;

    for (final placement in puzzle.words) {
      if (state.foundWords.contains(placement.word.word)) continue;
      if (placement.matchesCells(state.selectedCells)) {
        final coins = placement.isBonus ? 25 : 10;
        final newFound = {...state.foundWords, placement.word.word};
        final allRequired = puzzle.requiredWords
            .every((w) => newFound.contains(w.word.word));

        state = state.copyWith(
          selectedCells: [],
          foundWords: newFound,
          lastFoundWord: placement.word.word,
          coinsEarned: coins,
          puzzleComplete: allRequired,
        );

        _ref.read(playerProgressProvider.notifier).addCoins(coins);

        if (allRequired) {
          _ref
              .read(playerProgressProvider.notifier)
              .markPuzzleComplete(puzzle.id);
        }

        return coins;
      }
    }

    // No match — clear selection
    state = state.copyWith(selectedCells: []);
    return null;
  }

  void clearLastFound() {
    state = state.copyWith(clearLastFound: true);
  }

  // ── Hints ────────────────────────────────────────────────────

  /// Snapshot: reveal 1 letter on the grid.
  /// Binoculars: reveal 3 letters across unfound words.
  /// Local Guide: reveal an entire word (marks it found, awards coins).
  /// Returns a human-readable hint description, or null if can't afford.
  Future<String?> useHint(HintType type) async {
    final puzzle = state.puzzle;
    if (puzzle == null) return null;

    final cost = switch (type) {
      HintType.snapshot   => Hint.snapshot.cost,
      HintType.binoculars => Hint.binoculars.cost,
      HintType.localGuide => Hint.localGuide.cost,
    };

    final spent = await _ref
        .read(playerProgressProvider.notifier)
        .spendCoins(cost);
    if (!spent) return null;

    final unfound = puzzle.requiredWords
        .where((w) => !state.foundWords.contains(w.word.word))
        .toList();
    if (unfound.isEmpty) return null;

    switch (type) {
      case HintType.snapshot:
        // Reveal 1 unhinted cell from the first unfound word.
        final target = unfound.first;
        final cell = target.cells.firstWhere(
          (c) => !state.hintedCells.contains(c),
          orElse: () => target.cells.first,
        );
        state = state.copyWith(hintedCells: {...state.hintedCells, cell});
        return puzzle.grid[cell.$1][cell.$2];

      case HintType.binoculars:
        // Reveal 1 unhinted cell from each of up to 3 unfound words.
        final newCells = <(int, int)>{};
        for (final w in unfound.take(3)) {
          final cell = w.cells.firstWhere(
            (c) => !state.hintedCells.contains(c) && !newCells.contains(c),
            orElse: () => w.cells.first,
          );
          newCells.add(cell);
        }
        state = state.copyWith(hintedCells: {...state.hintedCells, ...newCells});
        return '${newCells.length} letters revealed';

      case HintType.localGuide:
        // Reveal all cells of one full word and mark it as found.
        final target = unfound.first;
        final allCells = target.cells.toSet();
        final newFound = {...state.foundWords, target.word.word};
        state = state.copyWith(
          hintedCells: {...state.hintedCells, ...allCells},
          foundWords: newFound,
        );
        // Award coins for finding the word.
        _ref.read(playerProgressProvider.notifier).addCoins(10);
        return target.word.word;
    }
  }
}

final puzzleProvider = StateNotifierProvider.family<PuzzleNotifier, PuzzleState,
    (String, int)>(
  (ref, args) => PuzzleNotifier(args.$1, args.$2, ref),
);
