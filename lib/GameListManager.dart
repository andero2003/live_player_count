import 'dart:async';
import 'package:live_player_count/FetchPlayers.dart';
import 'package:live_player_count/Game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameListManager {
  List<Game> games = [];
  late SharedPreferences prefs;
  GameListManager();

  Future<void> initialize() async {
    games = [];
    prefs = await SharedPreferences.getInstance();
    final gameIds = prefs.getStringList('games') ?? [];
    for (final id in gameIds) {
      final gameData = await fetchGameData(id);
      final iconUrl = await fetchIconData(id);
      games.add(Game(
        id: id,
        name: gameData['name'],
        playingCount: gameData['playing'],
        iconUrl: iconUrl,
      ));
    }
  }

  void addGame(Game game) {
    games.add(game);
    prefs.setStringList('games', games.map((e) => e.id).toList());
  }

  void removeGame(Game game) {
    games.remove(game);
    prefs.setStringList('games', games.map((e) => e.id).toList());
  }

  void updatePlayerCounts() async {
    for (final game in games) {
      final gameData = await fetchGameData(game.id);
      print('Player count: ${gameData['playing']}');
      game.updatePlayerCount(gameData['playing']);
    }
  }
}
