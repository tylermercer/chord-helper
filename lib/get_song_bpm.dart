import 'dart:convert';

import 'package:flutter/material.dart';

import 'API_KEY.dart';
import 'track_info.dart';

import 'package:http/http.dart' as http;

Future<int> getBpmFromTrackInfo(TrackInfo trackInfo) async {
  String id = await _getTrackId(trackInfo);
  return _getBpmFromTrackId(id);
}

Future<String> _getTrackId(TrackInfo trackInfo) async {
  var query = {
    'q' : '${trackInfo.artist} ${trackInfo.name}',
    'type' : 'track',
    'limit' : '1'
  };
  var url = "https://api.spotify.com/v1/search?${_encodeMap(query)}";

  var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $API_KEY"
      }
  );

  debugPrint(response.body);

  Map<String, dynamic> decoded = jsonDecode(response.body);
  
  return decoded['tracks']['items'][0]['id'];
}


Future<int> _getBpmFromTrackId(String id) async {
  var url = "https://api.spotify.com/v1/audio-features/$id";

  var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $API_KEY"
      }
  );

  debugPrint(response.body);

  var object = jsonDecode(response.body);

  return (object['tempo'] as double).round();
}

String _encodeMap(Map data) {
  return data.keys.map((key) => "$key=${data[key]}").join("&").replaceAll(" ", "+");
}