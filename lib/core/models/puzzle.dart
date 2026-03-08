import 'word_placement.dart';

class Puzzle {
  final String id;             // "london_01"
  final String chapterId;      // "london"
  final int number;            // 1–10
  /// 2D letter grid, row-major: grid[row][col].
  final List<List<String>> grid;
  final List<WordPlacement> words;
  /// The postcard story line revealed when this puzzle is solved.
  final String? postcardHint;

  const Puzzle({
    required this.id,
    required this.chapterId,
    required this.number,
    required this.grid,
    required this.words,
    this.postcardHint,
  });

  List<WordPlacement> get requiredWords => words.where((w) => !w.isBonus).toList();
  List<WordPlacement> get bonusWords => words.where((w) => w.isBonus).toList();

  int get rows => grid.length;
  int get cols => grid.isEmpty ? 0 : grid[0].length;

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String,
      chapterId: json['chapterId'] as String,
      number: json['number'] as int,
      grid: (json['grid'] as List)
          .map((row) => List<String>.from(row as List))
          .toList(),
      words: (json['words'] as List)
          .map((w) => WordPlacement.fromJson(w as Map<String, dynamic>))
          .toList(),
      postcardHint: json['postcardHint'] as String?,
    );
  }
}
