enum HintType { snapshot, binoculars, localGuide }

class Hint {
  final HintType type;
  final int cost;

  const Hint({required this.type, required this.cost});

  static const snapshot = Hint(type: HintType.snapshot, cost: 5);
  static const binoculars = Hint(type: HintType.binoculars, cost: 10);
  static const localGuide = Hint(type: HintType.localGuide, cost: 25);

  String get label {
    switch (type) {
      case HintType.snapshot:
        return 'Snapshot';
      case HintType.binoculars:
        return 'Binoculars';
      case HintType.localGuide:
        return 'Local Guide';
    }
  }

  String get description {
    switch (type) {
      case HintType.snapshot:
        return 'Reveal 1 letter';
      case HintType.binoculars:
        return 'Reveal 3 letters';
      case HintType.localGuide:
        return 'Reveal full word';
    }
  }
}
