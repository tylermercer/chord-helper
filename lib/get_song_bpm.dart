import 'dart:convert';

import 'package:flutter/material.dart';

import 'track_info.dart';

import 'package:http/http.dart' as http;

class SpotifyWebApi {
  static const String _baseUri = "https://api.spotify.com/v1";
  static const _baseTokenUri = "https://spotify-web-api-token.herokuapp.com/token";
  Future<String> accessToken;

  void refreshToken() async {
    accessToken = getToken();
  }

  Future<String> getToken() async {
    debugPrint("Getting token");
    var response = await http.get(_baseTokenUri);
    var decoded = jsonDecode(response.body);
    debugPrint("Got token: ${response.body}");
    return decoded['token'];
  }

  Future<int> getBpmFromTrackInfo(TrackInfo trackInfo) async {
    String id = await _getTrackId(trackInfo);
    return getBpmFromTrackId(id);
  }

  Future<int> getBpmFromTrackId(String id) async {
    var url = "$_baseUri/audio-features/$id";

    debugPrint("Getting bpm");
    var response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${await accessToken}"
        }
    );

    var decoded = jsonDecode(response.body);
    debugPrint("Got bpm: ${response.body}");
    return (decoded['tempo'] as double).round();
  }

  Future<String> _getTrackId(TrackInfo trackInfo) async {
    var query = {
      'q': '${trackInfo.artist} ${trackInfo.name}',
      'type': 'track',
      'limit': '1'
    };
    var url = "$_baseUri/search?${_encodeMap(query)}";

    debugPrint("Getting track id");
    var response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${await accessToken}"
        }
    );

    Map<String, dynamic> decoded = jsonDecode(response.body);

    debugPrint("Got track id: ${response.body}");
    var tracks = decoded['tracks'];
    if (tracks == null) return null;
    var items = tracks['items'];
    if (items == null) return null;
    var item0 = items[0];
    if (item0 == null) return null;
    return item0['id'];
  }

  String _encodeMap(Map data) {
    return data.keys.map((key) => "$key=${data[key]}").join("&").replaceAll(" ", "+");
  }
}