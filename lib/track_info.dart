class TrackInfo {
  final String name;
  final String album;
  final String artist;

  TrackInfo(this.name, this.album, this.artist);

  TrackInfo.fromMap(Map<String,dynamic> map) :
      this.name = map['track'],
      this.album = map['album'],
      this.artist = map['artist'];
}