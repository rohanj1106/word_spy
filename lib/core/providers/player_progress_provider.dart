import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_progress.dart';
import '../services/progress_service.dart';

final progressServiceProvider = Provider<ProgressService>(
  (_) => ProgressService(),
);

class PlayerProgressNotifier extends StateNotifier<PlayerProgress> {
  final ProgressService _service;

  PlayerProgressNotifier(this._service) : super(const PlayerProgress()) {
    _load();
  }

  Future<void> _load() async {
    state = await _service.load();
  }

  Future<void> addCoins(int amount) async {
    await _service.addCoins(amount);
    state = state.copyWith(coins: state.coins + amount);
  }

  /// Returns false if the player doesn't have enough coins.
  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) return false;
    await _service.spendCoins(amount);
    state = state.copyWith(coins: state.coins - amount);
    return true;
  }

  Future<void> markPuzzleComplete(String puzzleId) async {
    if (state.completedPuzzleIds.contains(puzzleId)) return;
    await _service.markPuzzleComplete(puzzleId);
    state = state.copyWith(
      completedPuzzleIds: {...state.completedPuzzleIds, puzzleId},
    );
  }

  Future<void> markChapterComplete(String chapterId) async {
    if (state.completedChapterIds.contains(chapterId)) return;
    await _service.markChapterComplete(chapterId);
    state = state.copyWith(
      completedChapterIds: {...state.completedChapterIds, chapterId},
      earnedStamps: {...state.earnedStamps, chapterId},
    );
  }
}

final playerProgressProvider =
    StateNotifierProvider<PlayerProgressNotifier, PlayerProgress>(
  (ref) => PlayerProgressNotifier(ref.read(progressServiceProvider)),
);
