class Game {
  final String id;
  final String name;

  int playingCount;
  final String iconUrl;

  Game({
    required this.id,
    required this.name,
    required this.playingCount,
    required this.iconUrl,
  });

  void updatePlayerCount(int count) {
    playingCount = count;
  }
}
