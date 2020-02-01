import 'track_info.dart';

Future<int> getBpmFromTrackInfo(TrackInfo trackInfo) async {
  return Future.delayed(Duration(milliseconds: 500))
      .then((onValue) => trackInfo.name.hashCode);
}