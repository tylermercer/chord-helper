import 'dart:math';

import 'package:flutter/material.dart';

class BpmBar extends StatelessWidget {
  @required final Function onSlowDown;
  @required final Function onSpeedUp;
  @required final int bpm;
  @required final int exponent;

  BpmBar({this.onSlowDown, this.onSpeedUp, this.bpm, this.exponent});

  get multiplier => pow(2, (exponent).abs());
  get multiplierString => exponent == 0 ? "" : (exponent >= 0 ? " (x$multiplier)" : " (x1/$multiplier)");

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
                ),
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
