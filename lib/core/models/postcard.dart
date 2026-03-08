class Postcard {
  final String chapterId;
  final String storyTitle;
  /// One line revealed per puzzle solved (10 lines total).
  final List<String> storyLines;
  final String fullImagePath;
  /// One fragment image per puzzle (10 total).
  final List<String> fragmentPaths;

  const Postcard({
    required this.chapterId,
    required this.storyTitle,
    required this.storyLines,
    required this.fullImagePath,
    required this.fragmentPaths,
  });

  factory Postcard.fromJson(String chapterId, Map<String, dynamic> json) {
    return Postcard(
      chapterId: chapterId,
      storyTitle: json['storyTitle'] as String,
      storyLines: List<String>.from(json['storyLines'] as List),
      fullImagePath: json['fullImagePath'] as String,
      fragmentPaths: List<String>.from(json['fragmentPaths'] as List),
    );
  }
}
