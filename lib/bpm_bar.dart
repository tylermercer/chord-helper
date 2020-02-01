import 'dart:math';

import 'package:flutter/material.dart';

class BpmBar extends StatelessWidget {
  final Function onSlowDown;
  final Function onSpeedUp;
  final int exponent;
  final int bpm;


  BpmBar({this.onSlowDown, this.onSpeedUp, this.exponent, this.bpm});

  get multiplierString => exponent == 0 ? "" : (exponent >= 0 ? " (x${pow(2, exponent)})" : " (x1/${pow(2, (exponent).abs())})");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      color: Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            iconSize: 40,
            icon: Icon(Icons.fast_rewind),
            onPressed: onSlowDown,
          ),
          Row(
            children: [
              if (bpm != null)
                Text(
                  "$bpm BPM",
                  style: TextStyle(
                    fontSize: 24,
                  )
                )
              ,
              if (bpm == null) Text("Loading..."),
              if (multiplierString != "") Text(multiplierString)
            ]
          ),
          IconButton(
            iconSize: 40,
            icon: Icon(Icons.fast_forward),
            onPressed: onSpeedUp,
          ),
        ],
      ),
    );
  }
}
