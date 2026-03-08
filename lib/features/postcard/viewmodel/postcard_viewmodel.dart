import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/chapter.dart';
import '../../../core/models/player_progress.dart';
import '../../../core/services/chapter_service.dart';
import '../../../core/providers/player_progress_provider.dart';

class PostcardState {
  final Chapter? chapter;
  final bool loading;

  const PostcardState({this.chapter, this.loading = true});

  PostcardState copyWith({Chapter? chapter, bool? loading}) {
    return PostcardState(
      chapter: chapter ?? this.chapter,
      loading: loading ?? this.loading,
    );
  }

  /// Which story lines have been revealed based on completed puzzles.
  List<bool> revealedLines(PlayerProgress progress) {
    if (chapter == null) return [];
    return List.generate(chapter!.puzzles.length, (i) {
      final puzzleId = chapter!.puzzles[i].id;
      return progress.completedPuzzleIds.contains(puzzleId);
    });
  }

  bool get fullyRevealed =>
      chapter != null &&
      revealedLines(const PlayerProgress(
        completedPuzzleIds: {},
      )).every((v) => v);
}

class PostcardNotifier extends StateNotifier<PostcardState> {
  final String _chapterId;
  final Ref _ref;

  PostcardNotifier(this._chapterId, this._ref)
      : super(const PostcardState()) {
    _load();
  }

  Future<void> _load() async {
    final chapter = await ChapterService.getById(_chapterId);
    state = state.copyWith(chapter: chapter, loading: false);
  }

  List<bool> get revealedLines {
    final progress = _ref.read(playerProgressProvider);
    return state.revealedLines(progress);
  }
}

final postcardProvider =
    StateNotifierProvider.family<PostcardNotifier, PostcardState, String>(
  (ref, chapterId) => PostcardNotifier(chapterId, ref),
);
