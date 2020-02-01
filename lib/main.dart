import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chord_helper/get_song_bpm.dart';
import 'package:flutter_chord_helper/track_info.dart';

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

  static const methodChannel = const MethodChannel("net.tylermercer.chordhelper/control");
  bool _isPlaying = false;
  int exponent = 0;

  get multiplier => pow(2, exponent);
  get multiplierString => exponent == 0 ? "" : (exponent >= 0 ? " (x$multiplier)" : " (x1/${pow(2, (exponent).abs())})");

  @override
  void initState() {
    musicInfo = rawMusicInfo.map<TrackInfo>((data) => TrackInfo.fromMap(data));
    musicBpm = musicInfo.asyncMap<int>((info) => getBpmFromTrackInfo(info));

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
          Container(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.fast_rewind),
                  onPressed: () {
                    setState(() {
                      exponent--;
                    });
                  },
                ),
                Row(
                  children: [
                    StreamBuilder<int>(
                      stream: musicBpm,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            "${snapshot.data} BPM",
                            style: TextStyle(
                              fontSize: 24,
                            )
                          );
                        } else {
                          return Text("Loading...");
                        }
                      }
                    ),
                    if (multiplierString != "") Text(multiplierString)
                  ]
                ),
                IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.fast_forward),
                  onPressed: () {
                    setState(() {
                      exponent++;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "A7",
                style: Theme.of(context).textTheme.display4.copyWith(
                  fontSize: 140
                ),
              ),
            ),
          ),
          Container(
            color: Colors.grey[300],
            padding: EdgeInsets.all(16),
            alignment: Alignment(0,0),
            child: Theme(
              data: Theme.of(context).copyWith(
                primaryTextTheme: TextTheme(

                )
              ),
              child: StreamBuilder<TrackInfo>(
                stream: musicInfo,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  } else {
                    return Text("No data");
                  }
                }
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 16),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.skip_previous),
                onPressed: _previous,
                ),
                if (_isPlaying) IconButton(
                  iconSize: 60,
                  icon: Icon(Icons.pause_circle_filled),
                  onPressed: _pause,
                ) else IconButton(
                  iconSize: 60,
                  icon: Icon(Icons.play_circle_filled),
                  onPressed: _play,
                ),
                IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.skip_next),
                  onPressed: _next,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _previous() {
    methodChannel.invokeMethod("goToPreviousSong");
  }

  void _next() {
    methodChannel.invokeMethod("goToNextSong");
  }

  void _play() {
    methodChannel.invokeMethod("playMusic");
  }

  void _pause() {
    methodChannel.invokeMethod("pauseMusic");
  }
}
