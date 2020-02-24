import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chord_helper/chord_flipper.dart';
import 'package:flutter_chord_helper/chord_sets.dart';
import 'package:flutter_chord_helper/spotify_web_api.dart';
import 'package:flutter_chord_helper/track_info.dart';

import 'bpm_bar.dart';
import 'media_controls_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: 'Chord Helper'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const eventChannel = const EventChannel("net.tylermercer.chordhelper/music");
  Stream<Map<String, dynamic>> rawMusicInfo = eventChannel.receiveBroadcastStream().map<Map<String, dynamic>>((e) => jsonDecode(e as String));
  Stream<TrackInfo> musicInfo;
  Stream<int> musicBpm;

  SpotifyWebApi api = new SpotifyWebApi();

  static const methodChannel = const MethodChannel("net.tylermercer.chordhelper/control");
  bool _isPlaying = false;
  int exponent = -2;

  double get multiplier => pow(2, exponent) * 1.0;

  ChordSet key = keys[0];

  @override
  void initState() {
    api.refreshToken();

    musicInfo = rawMusicInfo.map<TrackInfo>((data) => TrackInfo.fromMap(data)).distinct();
    musicBpm = musicInfo.asyncMap<int>((info) => api.getBpmFromTrackInfo(info));

    super.initState();
    getCurrentSongInfo();

    rawMusicInfo.listen((data) {
      if (data['playing'] != null) {
        setState(() {
          _isPlaying = data['playing'];
        });
      }
    });
  }

  void getCurrentSongInfo() async {
    methodChannel.invokeMethod("getMediaPlayState").then((playState) {
      if (playState == "PLAYING") {
        methodChannel.invokeMethod("pauseMusic");
        methodChannel.invokeMethod("playMusic");
      } else {
        methodChannel.invokeMethod("playMusic");
        methodChannel.invokeMethod("pauseMusic");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder<int>(
            stream: musicBpm,
            builder: (context, snapshot) {
              return BpmBar(
                onSlowDown: () {
                  setState(() {
                    exponent--;
                  });
                },
                onSpeedUp: () {
                  setState(() {
                    exponent++;
                  });
                },
                exponent: exponent,
                bpm: snapshot.hasData? snapshot.data : null,
              );
            }
          ),
          Expanded(
            child: StreamBuilder<int>(
              stream: musicBpm,
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return ChordFlipper(
                    bpm: snapshot.data,
                    multiplier: multiplier,
                    isPaused: !_isPlaying,
                    musicalKey: key
                  );
                else
                  return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          DropdownButton<ChordSet>(
            value: key,
            items: keys.map((k) => DropdownMenuItem(
              value: k,
              child: Text(k.name),
            )).toList(),
            onChanged: _keySelected,
          ),
          MediaControlsBar(
            isPlaying: _isPlaying,
            onPrevious: () => methodChannel.invokeMethod("goToPreviousSong"),
            onPlay: () => methodChannel.invokeMethod("playMusic"),
            onPause: () => methodChannel.invokeMethod("pauseMusic"),
            onNext: () => methodChannel.invokeMethod("goToNextSong"),
            musicInfo: musicInfo,
          )
        ],
      ),
    );
  }

  void _keySelected(ChordSet selected) {
    this.setState(() {
      this.key = selected;
    });
  }
}
