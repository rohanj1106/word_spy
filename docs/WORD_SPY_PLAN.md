# Word Spy — The Postcard Traveller
## Complete Development Plan (MVVM Architecture)

---

## Game Concept

Arthur (or Evelyn), a retired world traveller, receives mysterious postcards from cities worldwide.
Each postcard hides secret words scrambled into a letter grid. Players decode the hidden words to
reveal the full postcard — a beautifully illustrated scene with a short travel story.

**Core loop:** Solve puzzle → reveal postcard fragment → complete chapter → unlock next city → earn stamp

---

## Architecture: MVVM (Feature-first Hybrid)

Same architecture as the Trove skeleton (`mvvm-architecture` branch):
- **Model** → `lib/core/models/` (shared data structures)
- **Service** → `lib/core/services/` (data loading, persistence)
- **Provider** → `lib/core/providers/` (shared Riverpod state)
- **ViewModel** → `lib/features/*/viewmodel/` (feature business logic)
- **View** → `lib/features/*/view/` (Flutter UI, no logic)

---

## Project Structure

```
lib/
├── main.dart
├── app.dart                                  # GoRouter + MaterialApp
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                   # Postcard warm palette
│   │   ├── app_typography.dart               # Playfair Display + Lato
│   │   └── app_sizes.dart                    # Spacing / radius constants
│   ├── models/
│   │   ├── chapter.dart                      # City chapter + puzzles + postcard
│   │   ├── puzzle.dart                       # Letter set + required/bonus words
│   │   ├── word.dart                         # Word + definition + partOfSpeech
│   │   ├── postcard.dart                     # Postcard image + story fragments
│   │   ├── hint.dart                         # Hint type + cost
│   │   └── player_progress.dart              # Coins, stamps, unlocked chapters
│   ├── services/
│   │   ├── chapter_service.dart              # Load chapters from JSON assets
│   │   ├── progress_service.dart             # SharedPreferences read/write
│   │   └── auth_service.dart                 # Guest mode + Facebook sign-in stub
│   └── providers/
│       ├── player_progress_provider.dart     # Global player state (coins, stamps)
│       └── auth_provider.dart                # Auth state (guest/signed-in)
├── features/
│   ├── auth/
│   │   ├── view/
│   │   │   └── login_screen.dart             # Guest + Facebook login
│   │   └── viewmodel/
│   │       └── auth_viewmodel.dart
│   ├── chapter_select/
│   │   ├── view/
│   │   │   ├── chapter_select_screen.dart    # World map / chapter grid
│   │   │   └── widgets/
│   │   │       ├── chapter_card.dart         # City card with stamp + lock state
│   │   │       └── stamp_badge.dart          # Gold stamp overlay when complete
│   │   └── viewmodel/
│   │       ├── chapter_select_state.dart
│   │       └── chapter_select_viewmodel.dart
│   ├── puzzle/
│   │   ├── view/
│   │   │   ├── puzzle_screen.dart            # Main gameplay screen
│   │   │   └── widgets/
│   │   │       ├── letter_wheel.dart         # Swipe-to-select letter wheel
│   │   │       ├── word_slots.dart           # Answer blanks (_ _ _ _)
│   │   │       ├── postcard_strip.dart       # Partially revealed postcard
│   │   │       ├── hint_bar.dart             # Snapshot / Binoculars / Local Guide
│   │   │       └── coin_pop.dart             # +10 coin animation
│   │   └── viewmodel/
│   │       ├── puzzle_state.dart
│   │       └── puzzle_viewmodel.dart
│   ├── postcard/
│   │   ├── view/
│   │   │   └── postcard_reveal_screen.dart   # Full postcard after chapter complete
│   │   └── viewmodel/
│   │       └── postcard_viewmodel.dart
│   └── profile/
│       ├── view/
│       │   └── profile_screen.dart           # Coin balance, stamps, settings
│       └── viewmodel/
│           └── profile_viewmodel.dart
assets/
├── chapters/
│   ├── chapters.json                         # All chapter + puzzle data
│   └── postcards/
│       ├── london/
│       │   ├── postcard_full.jpg             # Full illustrated postcard
│       │   └── fragments/
│       │       ├── fragment_01.jpg           # Revealed after puzzle 1
│       │       ├── fragment_02.jpg           # Revealed after puzzle 2
│       │       └── ... (10 fragments)
│       ├── paris/
│       ├── tokyo/
│       └── ...
├── audio/
│   ├── bg_ambient.mp3                        # Soft travel ambient music
│   └── word_found.mp3                        # Success chime
└── animations/
    └── stamp.json                            # Lottie stamp reveal animation
```

---

## Data Models

### `chapter.dart`
```dart
enum ChapterStatus { locked, unlocked, completed }

class Chapter {
  final String id;           // "london", "paris", etc.
  final String city;         // "London"
  final String country;      // "United Kingdom"
  final String tagline;      // "Fog, Tea & Double-Deckers"
  final String flag;         // "🇬🇧"
  final List<Puzzle> puzzles; // 10 puzzles per chapter
  final Postcard postcard;
  final int coinsToUnlock;   // 0 for chapter 1, 50 for ch2, etc.

  factory Chapter.fromJson(Map<String, dynamic> json);
}
```

### `puzzle.dart`
```dart
class Puzzle {
  final String id;            // "london_01"
  final String chapterId;     // "london"
  final int number;           // 1-10
  final List<String> letterSet; // ["T","E","A","P","O","T"]
  final List<Word> requiredWords;
  final List<Word> bonusWords;
  final String? postcardHint; // "The kettle whistles at Baker Street..."

  factory Puzzle.fromJson(Map<String, dynamic> json);
}
```

### `word.dart`
```dart
class Word {
  final String word;
  final String definition;
  final String partOfSpeech;
  const Word({required this.word, required this.definition, required this.partOfSpeech});
}
```

### `postcard.dart`
```dart
class Postcard {
  final String chapterId;
  final String storyTitle;         // "A foggy morning in London..."
  final List<String> storyLines;   // 10 lines, one revealed per puzzle
  final String fullImagePath;      // "assets/chapters/postcards/london/postcard_full.jpg"
  final List<String> fragmentPaths; // 10 fragment image paths

  factory Postcard.fromJson(Map<String, dynamic> json);
}
```

### `hint.dart`
```dart
enum HintType { snapshot, binoculars, localGuide }

class Hint {
  final HintType type;
  final int cost; // snapshot=5, binoculars=10, localGuide=25

  static const snapshot   = Hint(type: HintType.snapshot,   cost: 5);
  static const binoculars = Hint(type: HintType.binoculars, cost: 10);
  static const localGuide = Hint(type: HintType.localGuide, cost: 25);
}
```

### `player_progress.dart`
```dart
class PlayerProgress {
  final int coins;                        // Travel Coins balance
  final Set<String> completedPuzzleIds;   // "london_01", "london_02"...
  final Set<String> completedChapterIds;  // "london", "paris"...
  final Set<String> earnedStamps;         // chapter IDs with stamps
  final String? guestId;                  // UUID for guest players
  final String? userId;                   // Firebase/Facebook UID

  PlayerProgress copyWith({...});
  factory PlayerProgress.empty();
}
```

---

## JSON Data Schema

### `assets/chapters/chapters.json`
```json
[
  {
    "id": "london",
    "city": "London",
    "country": "United Kingdom",
    "tagline": "Fog, Tea & Double-Deckers",
    "flag": "🇬🇧",
    "coinsToUnlock": 0,
    "postcard": {
      "storyTitle": "A Postcard from London",
      "storyLines": [
        "Arthur,",
        "The fog rolled in early today.",
        "I found a little tea shop near the Tower.",
        "Red buses everywhere — just like you said.",
        "The guards didn't crack a smile!",
        "Had a scone with clotted cream.",
        "Spotted a raven near the palace.",
        "Took the Tube to Camden.",
        "Tomorrow — Big Ben at sunrise.",
        "Wish you were here. — E."
      ],
      "fullImagePath": "assets/chapters/postcards/london/postcard_full.jpg",
      "fragmentPaths": [
        "assets/chapters/postcards/london/fragments/fragment_01.jpg",
        "...",
        "assets/chapters/postcards/london/fragments/fragment_10.jpg"
      ]
    },
    "puzzles": [
      {
        "id": "london_01",
        "chapterId": "london",
        "number": 1,
        "letterSet": ["T", "E", "A", "P", "O", "T"],
        "requiredWords": [
          { "word": "TEA",  "definition": "A hot drink made from dried leaves.", "partOfSpeech": "noun" },
          { "word": "POT",  "definition": "A rounded container used for cooking.", "partOfSpeech": "noun" },
          { "word": "TAP",  "definition": "A device for controlling water flow.", "partOfSpeech": "noun" }
        ],
        "bonusWords": [
          { "word": "POET", "definition": "A person who writes poems.", "partOfSpeech": "noun" }
        ],
        "postcardHint": "Arthur,"
      },
      {
        "id": "london_02",
        "chapterId": "london",
        "number": 2,
        "letterSet": ["F", "O", "G", "L", "S", "Y"],
        "requiredWords": [
          { "word": "FOG",  "definition": "Thick cloud of tiny water droplets.", "partOfSpeech": "noun" },
          { "word": "FLY",  "definition": "To move through the air.", "partOfSpeech": "verb" },
          { "word": "GOD",  "definition": "A superhuman being.", "partOfSpeech": "noun" }
        ],
        "bonusWords": [
          { "word": "FLOG", "definition": "Beat with a whip.", "partOfSpeech": "verb" }
        ],
        "postcardHint": "The fog rolled in early today."
      }
    ]
  }
]
```

---

## Services

### `chapter_service.dart`
```dart
class ChapterService {
  static List<Chapter>? _cache;

  static Future<List<Chapter>> loadAll() async {
    if (_cache != null) return _cache!;
    final json = await rootBundle.loadString('assets/chapters/chapters.json');
    _cache = (jsonDecode(json) as List)
        .map((e) => Chapter.fromJson(e))
        .toList();
    return _cache!;
  }

  static Future<Chapter?> getById(String id) async {
    final all = await loadAll();
    return all.firstWhereOrNull((c) => c.id == id);
  }
}
```

### `progress_service.dart`
```dart
class ProgressService {
  static const _keys = (
    coins: 'coins',
    completedPuzzles: 'completed_puzzle_ids',
    completedChapters: 'completed_chapter_ids',
    stamps: 'earned_stamps',
    guestId: 'guest_id',
  );

  Future<PlayerProgress> load();
  Future<void> save(PlayerProgress progress);
  Future<void> addCoins(int amount);
  Future<void> markPuzzleComplete(String puzzleId);
  Future<void> markChapterComplete(String chapterId);
}
```

### `auth_service.dart`
```dart
// Phase 0: guest-only stub
// Phase 2: wire up Facebook + Firebase Auth
abstract class AuthService {
  Future<String> signInAsGuest();   // Returns guest UUID
  Future<String?> signInWithFacebook(); // Returns userId or null
  Future<void> signOut();
}

class StubAuthService implements AuthService {
  @override
  Future<String> signInAsGuest() async {
    return const Uuid().v4();
  }
  // ...
}
```

---

## ViewModels

### `auth_viewmodel.dart`
```dart
enum AuthStatus { idle, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  final bool isGuest;
  final String? userId;
}

class AuthNotifier extends StateNotifier<AuthState> {
  Future<void> continueAsGuest();
  Future<void> signInWithFacebook();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
```

### `chapter_select_viewmodel.dart`
```dart
class ChapterSelectState {
  final List<Chapter> chapters;
  final bool loading;
  // Helpers derived from PlayerProgress:
  bool isLocked(Chapter c, PlayerProgress p);
  bool isCompleted(Chapter c, PlayerProgress p);
  int puzzlesCompleted(Chapter c, PlayerProgress p);
}

class ChapterSelectNotifier extends StateNotifier<ChapterSelectState> {
  ChapterSelectNotifier(this._ref) : super(const ChapterSelectState()) {
    _load();
  }
  Future<void> _load();
}

final chapterSelectProvider =
    StateNotifierProvider<ChapterSelectNotifier, ChapterSelectState>(...);
```

### `puzzle_state.dart`
```dart
class PuzzleState {
  final Puzzle? puzzle;
  final bool loading;
  final String currentInput;        // Letters selected so far
  final Set<String> foundRequired;  // Required words found
  final Set<String> foundBonus;     // Bonus words found
  final Set<int> revealedLetters;   // Indices revealed by hints
  final bool puzzleComplete;
  final String? lastFoundWord;      // Triggers success animation
  final int? coinsEarned;           // Triggers coin pop

  PuzzleState copyWith({...});
  const PuzzleState();
}
```

### `puzzle_viewmodel.dart`
```dart
// Keyed by puzzleId (StateNotifierProvider.family)
class PuzzleNotifier extends StateNotifier<PuzzleState> {
  PuzzleNotifier(this._puzzleId, this._ref) : super(const PuzzleState()) {
    _loadPuzzle();
  }

  void addLetter(String letter);
  void removeLetter();
  void clearInput();

  /// Returns coins earned (10 required, 25 bonus) or null if invalid word
  int? submitWord();

  /// Applies hint — deducts coins from player progress
  void useHint(HintType hint, String targetWord);

  void _checkCompletion();
}

final puzzleProvider =
    StateNotifierProvider.family<PuzzleNotifier, PuzzleState, String>(
      (ref, puzzleId) => PuzzleNotifier(puzzleId, ref),
    );
```

### `postcard_viewmodel.dart`
```dart
class PostcardState {
  final Chapter? chapter;
  final List<bool> revealedFragments; // which of 10 are revealed
  final bool fullyRevealed;
}

class PostcardNotifier extends StateNotifier<PostcardState> {
  PostcardNotifier(this._chapterId, this._ref);
  // Derives revealed fragments from PlayerProgress.completedPuzzleIds
}

final postcardProvider =
    StateNotifierProvider.family<PostcardNotifier, PostcardState, String>(...);
```

---

## Navigation (GoRouter)

| Route | Screen |
|---|---|
| `/` | Redirects to `/login` or `/chapters` based on auth state |
| `/login` | LoginScreen |
| `/chapters` | ChapterSelectScreen |
| `/puzzle/:chapterId/:puzzleNumber` | PuzzleScreen |
| `/postcard/:chapterId` | PostcardRevealScreen |
| `/profile` | ProfileScreen |

---

## Design System

### Color Palette (`app_colors.dart`)
```dart
class AppColors {
  // Warm postcard palette
  static const primary      = Color(0xFF2C5F8A);  // Postal blue
  static const accent       = Color(0xFFE8934A);  // Sunset orange (coins)
  static const background   = Color(0xFFF8F0DC);  // Aged paper
  static const surface      = Color(0xFFFFFFFF);  // Card white
  static const inkDark      = Color(0xFF1C1C2E);  // Ink text
  static const inkLight     = Color(0xFF6B7280);  // Secondary text
  static const stampGold    = Color(0xFFD4A843);  // Stamp gold
  static const success      = Color(0xFF2E9B6A);  // Word found green
  static const error        = Color(0xFFD64045);  // Wrong word red

  // Chapter card gradients per city feel
  static const londonGrad   = [Color(0xFF4A7FA5), Color(0xFF8DB8D4)];
  static const parisGrad    = [Color(0xFF9B5E8A), Color(0xFFC89AC0)];
  static const tokyoGrad    = [Color(0xFFD45A6A), Color(0xFFF0A0A8)];
}
```

### Typography (`app_typography.dart`)
- **Display / Headings**: Playfair Display (serif, gives travel journal feel)
- **Body / UI**: Lato (clean, readable)
- **Switchable**: Lato → OpenDyslexic for accessibility

---

## Coin Economy

| Action | Coins |
|---|---|
| Solve required word | +10 |
| Solve bonus word | +25 |
| Complete chapter (all 10 puzzles) | +100 + Digital Stamp |
| Daily login bonus | +20 |
| **Hint: Snapshot** (reveal 1 letter) | -5 |
| **Hint: Binoculars** (reveal 3 letters) | -10 |
| **Hint: Local Guide** (reveal full word) | -25 |

Starting coins: **50** (enough for a few hints to learn the game)

---

## Chapter Progression

| Chapter | City | Difficulty | Word Length | Unlock Cost |
|---|---|---|---|---|
| 1 | London | Beginner | 3-4 letters | Free |
| 2 | Paris | Beginner | 3-4 letters | 50 coins |
| 3 | Tokyo | Easy | 3-5 letters | 100 coins |
| 4 | New York | Easy | 3-5 letters | 150 coins |
| 5 | Cairo | Medium | 4-6 letters | 200 coins |
| 6 | Rio de Janeiro | Medium | 4-6 letters | 250 coins |
| 7 | Sydney | Hard | 4-7 letters | 300 coins |
| 8 | Mumbai | Hard | 4-7 letters | 350 coins |
| 9 | Reykjavik | Expert | 5-7 letters | 400 coins |
| 10 | Marrakech | Expert | 5-7 letters | 500 coins |

---

## Phase Roadmap

### Phase 0 — Project Skeleton (Week 1)
> Auth/login skipped — app starts directly on Chapter Select screen.
- [ ] Define all data models with `fromJson` / `copyWith`
- [ ] Implement `ChapterService` (JSON loading + in-memory cache)
- [ ] Implement `ProgressService` (SharedPreferences CRUD)
- [ ] Add `player_progress_provider.dart`
- [ ] GoRouter wired (no /login — starts at /chapters)
- [ ] All screens as skeleton scaffolds (no logic)
- [ ] Create `chapters.json` with 2 complete chapters (London + Paris)
- [ ] Run clean on iOS Simulator and Android Emulator

### Phase 1 — Core Gameplay (Week 2-3)
- [ ] Letter wheel: swipe gesture, letter selection highlight, clear on lift
- [ ] Word slots widget: animated fill as letters selected, shake on wrong word
- [ ] Word validation in PuzzleViewModel
- [ ] Found-word celebration: success animation + coin pop (+10 / +25)
- [ ] Postcard strip: progressive reveal per puzzle solved
- [ ] Puzzle complete flow → navigate to PostcardRevealScreen
- [ ] Chapter select screen: locked/unlocked/completed states
- [ ] Chapter unlock with coins

### Phase 2 — Retention & Polish (Week 4)
- [ ] Hint system: Snapshot / Binoculars / Local Guide (coin deduction)
- [ ] Definition card: shows word definition after finding it
- [ ] Postcard reveal screen: full illustrated card + story text animation
- [ ] Stamp animation (Lottie) on chapter complete
- [ ] Bonus word detection (purple highlight, +25 coins)
- [ ] Daily login bonus (+20 coins)
- [ ] Profile screen: coin balance, stamps collected, progress

### Phase 3 — Auth & Persistence (Week 5-6)
- [ ] Optional login: Facebook Sign-In (firebase_auth + facebook_auth package)
- [ ] Guest → signed-in migration (keep SharedPrefs progress)
- [ ] Cloud save (Firestore) for cross-device sync

### Phase 4 — Content & Store (Week 7+)
- [ ] 10 complete chapters (all cities, illustrated postcards)
- [ ] In-app purchase: Coin packs (100 / 500 / 1200 coins)
- [ ] Premium chapter unlock (one-time purchase per city pack)
- [ ] App Store + Play Store submission

---

## Dependency List (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  shared_preferences: ^2.3.0
  google_fonts: ^6.2.1
  audioplayers: ^6.0.0
  lottie: ^3.0.0
  flutter_animate: ^4.5.0
  uuid: ^4.0.0                    # For guest ID generation
  collection: ^1.18.0             # firstWhereOrNull helper

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
```

---

## First 5 Puzzles — London Chapter (Complete Data)

| # | Letter Set | Required Words | Bonus Words | Story Line Revealed |
|---|---|---|---|---|
| 1 | T E A P O T | TEA, POT, TAP | POET | "Arthur," |
| 2 | F O G L S Y | FOG, FLY, LOG | FLOG | "The fog rolled in early today." |
| 3 | B U S R E D | BUS, RED, RUB | RUDE | "I found a tea shop near the Tower." |
| 4 | T O W E R S | TOWER, STORE, WORE | STREW | "Red buses everywhere — just like you said." |
| 5 | G U A R D S | GUARD, DRUG, DUG | GRADS | "The guards didn't crack a smile!" |

---

## Testing Strategy

```
test/
├── unit/
│   ├── models/
│   │   └── chapter_test.dart          # fromJson parsing
│   ├── services/
│   │   └── chapter_service_test.dart  # JSON loading
│   └── viewmodels/
│       └── puzzle_viewmodel_test.dart # Word validation, hint logic, coin math
└── widget/
    ├── letter_wheel_test.dart
    └── word_slots_test.dart
```

---

## What's NOT in Scope (Yet)
- Multiplayer / leaderboards
- Push notifications
- Real AI puzzle generation
- Offline-first sync conflict resolution
- Social sharing of completed postcards (Phase 4+)
