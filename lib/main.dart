import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Stream music = eventChannel.receiveBroadcastStream().map<Map<String, dynamic>>((e) => jsonDecode(e as String));

  static const methodChannel = const MethodChannel("net.tylermercer.chordhelper/control");
  bool isPlaying = false;
  int exponent = 0;

  get multiplier => pow(2, exponent);
  get multiplierString => exponent == 0 ? "" : (exponent >= 0 ? " (x$multiplier)" : " (x1/${pow(2, (exponent).abs())})");

  @override
  void initState() {
    super.initState();
    initIsPlaying();

    music.listen((data) {
      if (data['command'] == "") {

      }
    });
  }

  void initIsPlaying() async {
    methodChannel.invokeMethod("getMediaPlayState").then((playState) {
      setState(() {
        isPlaying = playState == "PLAYING";
      });

      if (playState == "PLAYING") {
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
                    Text(
                      "200 BPM",
                      style: TextStyle(
                        fontSize: 24,
                      )
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
              child: StreamBuilder<Map<String, dynamic>>(
                stream: music,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.values.join(", "));
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
                onPressed: () => methodChannel.invokeMethod("goToPreviousSong"),
                ),
                if (isPlaying) IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.pause_circle_filled),
                  onPressed: () => methodChannel.invokeMethod("pauseMusic"),
                ) else IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.play_circle_filled),
                  onPressed: () => methodChannel.invokeMethod("playMusic"),
                ),
                IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.skip_next),
                  onPressed: () => methodChannel.invokeMethod("goToNextSong"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
