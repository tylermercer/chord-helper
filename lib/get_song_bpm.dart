import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_keys.dart';
import 'track_info.dart';

import 'package:http/http.dart' as http;

var _prefs = SharedPreferences.getInstance();

Future<int> getBpmFromTrackInfo(TrackInfo trackInfo) async {

  debugPrint("FOOBAR 1");

  var prefs = await _prefs;

  debugPrint("FOOBAR 2");

  int expirationTime = prefs.containsKey("AUTH_EXP_TIME") ? prefs.getInt("AUTH_EXP_TIME") : 0;
  String authToken;
  if (DateTime.now().millisecondsSinceEpoch > expirationTime) {

    debugPrint("FOOBAR 3");
    authToken = await _getNewAuthToken(prefs);

    debugPrint("FOOBAR 4");
  }
  else {
    authToken = prefs.getString("AUTH_TOKEN");
  }

  debugPrint("FOOBAR");

  String id = await _getTrackId(trackInfo, authToken);
  return _getBpmFromTrackId(id, authToken);
}

Future<String> _getNewAuthToken(SharedPreferences prefs) async {

  debugPrint("FOOBAR 3.1");

  var url = "https://accounts.spotify.com/api/token";

  var response = await http.post(url,
    body: {
      'grant_type' : 'client_credentials'
    },
    headers: {
      "Authorization" : "Basic $client_ID:$client_secret"
    }
  );

  debugPrint("FOOBAR 3.2");

  var decoded = jsonDecode(response.body);

  debugPrint("FOOBAR 3.3");
  debugPrint(response.body);
  var authToken = decoded['access_token'];
  var ttl = decoded['expires_in'] as int;

  debugPrint("FOOBAR 3.4");

  debugPrint("New Auth Token:" + authToken);

  await prefs.setString("AUTH_TOKEN", authToken);
  await prefs.setInt("AUTH_EXP_TIME", DateTime.now().millisecondsSinceEpoch + ttl - 1000);

  return authToken;
}

Future<String> _getTrackId(TrackInfo trackInfo, String authToken) async {
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
        "Authorization": "Bearer $authToken"
      }
  );

  debugPrint(response.body);

  Map<String, dynamic> decoded = jsonDecode(response.body);

  return decoded['tracks']['items'][0]['id'];
}


Future<int> _getBpmFromTrackId(String id, String authToken) async {
  var url = "https://api.spotify.com/v1/audio-features/$id";

  var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $authToken"
      }
  );

  var object = jsonDecode(response.body);

  return (object['tempo'] as double).round();
}

String _encodeMap(Map data) {
  return data.keys.map((key) => "$key=${data[key]}").join("&").replaceAll(" ", "+");
}
