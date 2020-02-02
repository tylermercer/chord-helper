import 'package:flutter/material.dart';
import 'package:flutter_chord_helper/track_info.dart';

class MediaControlsBar extends StatelessWidget {
  @required final Stream<TrackInfo> musicInfo;
  @required final Function onPrevious;
  @required final Function onPlay;
  @required final Function onPause;
  @required final Function onNext;
  @required final bool isPlaying;

  MediaControlsBar({this.musicInfo, this.onPrevious, this.onPlay, this.onPause,
      this.onNext, this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[300],
          padding: EdgeInsets.all(16),
          alignment: Alignment(0,0),
          child: StreamBuilder<TrackInfo>(
              stream: musicInfo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      Text(snapshot.data.artist + " - " + snapshot.data.album, style: Theme.of(context).textTheme.caption),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(snapshot.data.name, style: Theme.of(context).textTheme.body2),
                      ),
                    ],
                  );
                } else {
                  return Text("No data");
                }
              }
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
                onPressed: onPrevious,
              ),
              if (isPlaying) IconButton(
                iconSize: 60,
                icon: Icon(Icons.pause_circle_filled),
                onPressed: onPause,
              ) else IconButton(
                iconSize: 60,
                icon: Icon(Icons.play_circle_filled),
                onPressed: onPlay,
              ),
              IconButton(
                iconSize: 40,
                icon: Icon(Icons.skip_next),
                onPressed: onNext,
              ),
            ],
          ),
        )
      ],
    );
  }
}
