class Word {
  final String word;
  final String definition;
  final String partOfSpeech;
  final String? etymology;

  const Word({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    this.etymology,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: (json['word'] as String).toUpperCase(),
      definition: json['definition'] as String,
      partOfSpeech: json['partOfSpeech'] as String? ?? 'unknown',
      etymology: json['etymology'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'definition': definition,
        'partOfSpeech': partOfSpeech,
        if (etymology != null) 'etymology': etymology,
      };
}
