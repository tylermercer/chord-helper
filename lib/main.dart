import 'dart:convert';

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
  static const channel = const EventChannel("net.tylermercer.chordhelper/music");
  Stream music = channel.receiveBroadcastStream().map<Map<String, dynamic>>((e) => jsonDecode(e as String));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<Map<String, dynamic>>(
              stream: music,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.values.join(", "));
                } else {
                  return Text("No data");
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
