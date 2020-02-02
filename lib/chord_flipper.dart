import 'package:flutter/material.dart';
import 'package:flutter_chord_helper/chord_list.dart';

class ChordFlipper extends StatefulWidget {
  final int bpm;
  final double multiplier;
  final bool isPaused;

  const ChordFlipper({Key key, this.bpm, this.multiplier, this.isPaused}) : super(key: key);

  @override
  _ChordFlipperState createState() => _ChordFlipperState();
}

class _ChordFlipperState extends State<ChordFlipper> {
  List<String> _chords = List<String>.from(chords);
  Stream<String> _chordSequence;
  String _lastChord;

  @override
  void initState() {
    super.initState();
    _chords.shuffle();
    _lastChord = _chords.last;
    if (widget.isPaused) {
      Stream.value(_chords[0]).asBroadcastStream();
    }
    else {
      _start();
    }
  }

  void _start() {
    setState(() {
      _chords.shuffle();
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

  @override
  void didUpdateWidget(ChordFlipper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused) {
      _stop();
    }
    else {
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<String>(
        stream: _chordSequence,
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Text(
              snapshot.data,
              style: Theme.of(context).textTheme.display4.copyWith(
                  fontSize: 140
              ),
            );
          else
            return CircularProgressIndicator();
        }
      ),
    );
  }
}
