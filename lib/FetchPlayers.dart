import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> fetchIconData(String id) async {
  final response = await http.get(Uri.parse(
      'https://thumbnails.roblox.com/v1/games/icons?universeIds=$id&returnPolicy=PlaceHolder&size=256x256&format=Png&isCircular=false'));
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    final data = json.decode(response.body);
    return data['data'][0]['imageUrl'];
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load');
  }
}

Future<dynamic> fetchGameData(String id) async {
  final response = await http.get(Uri.parse('https://games.roblox.com/v1/games?universeIds=$id'));
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    final data = json.decode(response.body);
    return data['data'][0];
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load');
  }
}
