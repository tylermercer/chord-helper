class ChordSet {
  final String name;
  final List<String> primaryChords;
  final List<String> additionalChords;
  final bool shuffle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChordSet &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              primaryChords == other.primaryChords &&
              additionalChords == other.additionalChords;

  @override
  int get hashCode =>
      name.hashCode ^
      primaryChords.hashCode ^
      additionalChords.hashCode;

  ChordSet({this.name, this.primaryChords, this.additionalChords, this.shuffle = true});

  List<String> toWeightedChordList() {
    List<String> res = [];
    if (this.additionalChords.length > 0) {
      List<String> primary = List.from(primaryChords);
      for (var chord in this.additionalChords) {
        if (shuffle)
          primary.shuffle();
        else //When not shuffled, add the primary list twice so that it's practiced in sequence
          res.addAll(primary);
        res.addAll(primary);
        res.add(chord);
      }
    } else {
      res.addAll(primaryChords);
      if (shuffle) res.shuffle();
    }
    return res;
  }
}

List<ChordSet> keys = [
  ChordSet(
    name: "D Major",
    primaryChords: [
      "D",
      "G",
      "A7",
    ],
    additionalChords: [
      "E7",
      "Em",
      "Bm/D",
      "Am",
      "Dm",
    ]
  ),
  ChordSet(
    name: "G Major",
    primaryChords: [
      "G",
      "C",
      "D7",
    ],
    additionalChords: [
      "A7",
      "Am",
      "B7",
      "Em",
      "D",
    ]
  ),
  ChordSet(
    name: "C Major",
    primaryChords: [
      "C",
      "F",
      "G7",
    ],
    additionalChords: [
      "Em",
      "Dm"
    ]
  ),
  ChordSet(
    name: "A Major",
    primaryChords: [
      "A",
      "D",
      "E7",
    ],
    additionalChords: [
      "B7",
    ]
  ),
  ChordSet(
    name: "E Major",
    primaryChords: [
      "E",
      "A",
      "B7",
    ],
  ),
  ChordSet(
    name: "E Minor",
    primaryChords: [
      "Em",
      "Am",
      "B7"
    ]
  ),
  ChordSet(
    name: "A Minor",
    primaryChords: [
      "Am",
      "Dm",
      "E7"
    ]
  ),
  ChordSet(
    name: "One Foot",
    primaryChords: [
      "Am",
      "F",
      "C",
      "G"
    ],
    shuffle: false
  ),
  ChordSet(
    name: "Safe and Sound",
    primaryChords: [
      "F",
      "C",
      "Am",
      "G"
    ],
    shuffle: false
  ),
  ChordSet(
    name: "Oh My Stars",
    primaryChords: [
      "C",
      "Em",
      "Am",
      "G",
    ],
    additionalChords: [
      "F"
    ],
    shuffle: false
  ),
  ChordSet(
    name: "Graduate",
    primaryChords: [
      "C",
      "G",
      "D"
    ]
  ),
  ChordSet(
    name: "Something Just Like This",
    primaryChords: [
      "G",
      "A",
      "Bm",
      "D"
    ],
    additionalChords: [
      "F#m"
    ]
  ),
];
