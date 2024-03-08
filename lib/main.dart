import 'dart:math';

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:live_player_count/FetchPlayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'Game.dart';
import 'GameListManager.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final GameListManager gameListManager = GameListManager();
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: gameListManager.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return MainScreen(gameListManager: gameListManager);
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final GameListManager gameListManager;

  const MainScreen({
    super.key,
    required this.gameListManager,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _controller = TextEditingController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        widget.gameListManager.updatePlayerCounts();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter game id',
              hintText: 'Enter game id',
              prefixIcon: Icon(Icons.gamepad),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffix: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isEmpty) {
                    return;
                  }
                  final id = _controller.text;
                  if (widget.gameListManager.games.any((element) => element.id == id)) {
                    return;
                  }
                  _controller.clear();
                  Future.wait([fetchGameData(id), fetchIconData(id)]).then((value) {
                    final gameData = value[0];
                    final String name = gameData['name'];
                    final int playingCount = gameData['playing'];

                    final String iconUrl = value[1];

                    setState(() {
                      widget.gameListManager.addGame(Game(
                        id: id,
                        name: name,
                        playingCount: playingCount,
                        iconUrl: iconUrl,
                      ));
                    });
                  });
                },
                child: Text('ADD'),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.gameListManager.games.length,
            itemBuilder: (context, index) {
              final game = widget.gameListManager.games[index];
              return ListTile(
                leading: Image.network(game.iconUrl),
                title: Text(
                  game.name,
                ),
                subtitle: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedDigitWidget(
                    textStyle: TextStyle(color: Colors.white, fontSize: 20),
                    value: game.playingCount,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      widget.gameListManager.removeGame(game);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
