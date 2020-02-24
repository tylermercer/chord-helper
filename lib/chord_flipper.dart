import 'package:flutter/material.dart';

import 'chord_sets.dart';

class ChordFlipper extends StatefulWidget {
  final int bpm;
  final double multiplier;
  final bool isPaused;
  final ChordSet musicalKey;

  const ChordFlipper({Key key, this.bpm, this.multiplier, this.isPaused, this.musicalKey}) : super(key: key);

  @override
  _ChordFlipperState createState() => _ChordFlipperState();
}

class _ChordFlipperState extends State<ChordFlipper> {
  List<String> _chords;
  Stream<String> _chordSequence;
  String _lastChord;

  @override
  void initState() {
    super.initState();
    _initChordsList();
    _lastChord = _chords.last;
    if (widget.isPaused) {
      _chordSequence = Stream.value(_chords[0]).asBroadcastStream();
    }
    else {
      _start();
    }
  }

  void _start() {
    setState(() {
      _initChordsList();
      _chordSequence = Stream.periodic(Duration(milliseconds: (60000/(widget.multiplier * widget.bpm)).round()), (int computationCount) {
        return _chords[computationCount % _chords.length];
      }).asBroadcastStream();
      _chordSequence.listen((d) => setState(() { _lastChord = d;}));
    });
  }

  void _stop() async {
    setState(() {
      _chordSequence = Stream.value(_lastChord).asBroadcastStream();
    });
  }

  void _initChordsList() {
    _chords = widget.musicalKey.toWeightedChordList();
  }

  @override
  void didUpdateWidget(ChordFlipper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused) {
      _stop();
    }
    else {
      _start();
    }
    if (widget.musicalKey != oldWidget.musicalKey) {
      _initChordsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<String>(
        stream: _chordSequence,
        builder: (context, snapshot) {
          var data = snapshot.hasData ? snapshot.data : _lastChord;
          return Text(
            data,
            style: Theme.of(context).textTheme.display4.copyWith(
                fontSize: 140
            ),
          );
        }
      ),
    );
  }
}
