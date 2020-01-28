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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  String _batteryLevel = "100";
  static const channel = const EventChannel("samples.flutter.dev/music");
  Stream music;


  @override
  void initState() {
    super.initState();
    music = channel.receiveBroadcastStream().map<String>((e) => e as String);
  }

//  Future<void> _getBatteryLevel() async {
//    String batteryLevel;
//    try {
//      final int result = await ;
//      batteryLevel = 'Music info: $result %.';
//    } on PlatformException catch (e) {
//      batteryLevel = "Failed to get music info: '${e.message}'.";
//    }
//
//    setState(() {
//      _batteryLevel = batteryLevel;
//    });
//  }

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
            StreamBuilder<String>(
              stream: music,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data,
                    style: Theme.of(context).textTheme.display1,
                  );
                } else {
                  return Text("No data");
                }
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {

          });
        },
      ),
    );
  }
}
