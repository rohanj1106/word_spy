import 'puzzle.dart';
import 'postcard.dart';

class Chapter {
  final String id;           // "london"
  final String city;         // "London"
  final String country;      // "United Kingdom"
  final String tagline;      // "Fog, Tea & Double-Deckers"
  final String flag;         // "🇬🇧"
  final int coinsToUnlock;   // 0 = free, >0 = locked behind coin cost
  final List<Puzzle> puzzles; // 10 puzzles per chapter
  final Postcard postcard;

  const Chapter({
    required this.id,
    required this.city,
    required this.country,
    required this.tagline,
    required this.flag,
    required this.coinsToUnlock,
    required this.puzzles,
    required this.postcard,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return Chapter(
      id: id,
      city: json['city'] as String,
      country: json['country'] as String,
      tagline: json['tagline'] as String,
      flag: json['flag'] as String,
      coinsToUnlock: json['coinsToUnlock'] as int? ?? 0,
      puzzles: (json['puzzles'] as List)
          .map((p) => Puzzle.fromJson(p as Map<String, dynamic>))
          .toList(),
      postcard: Postcard.fromJson(id, json['postcard'] as Map<String, dynamic>),
    );
  }
}
