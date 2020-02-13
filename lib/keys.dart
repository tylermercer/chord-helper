import 'package:flutter/material.dart';

class MusicalKey {
  final String name;
  final List<String> primaryChords;
  final List<String> additionalChords;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MusicalKey &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              primaryChords == other.primaryChords &&
              additionalChords == other.additionalChords;

  @override
  int get hashCode =>
      name.hashCode ^
      primaryChords.hashCode ^
      additionalChords.hashCode;

  MusicalKey({this.name, this.primaryChords, this.additionalChords});

  List<String> toWeightedShuffledChordList() {
    List<String> res = [];
    if (this.additionalChords.length > 0) {
      List<String> primary = List.from(primaryChords);
      for (var chord in this.additionalChords) {
        primary.shuffle();
        res.addAll(primary);
        res.add(chord);
      }
    } else {
      res.addAll(primaryChords);
      res.shuffle();
    }
    return res;
  }
}

List<MusicalKey> keys = [
  MusicalKey(
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
  MusicalKey(
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
  MusicalKey(
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
  MusicalKey(
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
  MusicalKey(
    name: "E Major",
    primaryChords: [
      "E",
      "A",
      "B7",
    ],
  ),
  MusicalKey(
    name: "E Minor",
    primaryChords: [
      "Em",
      "Am",
      "B7"
    ]
  ),
  MusicalKey(
    name: "A Minor",
    primaryChords: [
      "Am",
      "Dm",
      "E7"
    ]
  )
];
