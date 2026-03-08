import 'word.dart';

enum SearchDirection { horizontal, vertical, diagonalDown }

/// A word placed inside the word search grid at a specific position.
class WordPlacement {
  final Word word;
  final int startRow;
  final int startCol;
  final SearchDirection direction;
  final bool isBonus;

  const WordPlacement({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
    this.isBonus = false,
  });

  factory WordPlacement.fromJson(Map<String, dynamic> json) {
    return WordPlacement(
      word: Word.fromJson(json),
      startRow: json['startRow'] as int,
      startCol: json['startCol'] as int,
      direction: SearchDirection.values.firstWhere(
        (d) => d.name == (json['direction'] as String),
        orElse: () => SearchDirection.horizontal,
      ),
      isBonus: json['isBonus'] as bool? ?? false,
    );
  }

  /// Returns all (row, col) cells this word occupies in order.
  List<(int, int)> get cells {
    return List.generate(word.word.length, (i) {
      switch (direction) {
        case SearchDirection.horizontal:
          return (startRow, startCol + i);
        case SearchDirection.vertical:
          return (startRow + i, startCol);
        case SearchDirection.diagonalDown:
          return (startRow + i, startCol + i);
      }
    });
  }

  /// Returns true if the given (row, col) sequence matches this word's cells.
  bool matchesCells(List<(int, int)> selected) {
    if (selected.length != cells.length) return false;
    for (var i = 0; i < cells.length; i++) {
      if (selected[i] != cells[i]) return false;
    }
    return true;
  }
}
