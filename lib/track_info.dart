class TrackInfo {
  final String name;
  final String album;
  final String artist;

  TrackInfo(this.name, this.album, this.artist);

  TrackInfo.fromMap(Map<String,dynamic> map) :
      this.name = map['track'],
      this.album = map['album'],
      this.artist = map['artist'];

  String toString() => '${this.artist} / ${this.album} / ${this.name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TrackInfo &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              album == other.album &&
              artist == other.artist;

  @override
  int get hashCode =>
      name.hashCode ^
      album.hashCode ^
      artist.hashCode;
}