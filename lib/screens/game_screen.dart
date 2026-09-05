import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../data/database/database.dart';
import '../data/repositories/game_repository.dart';
import '../game/dungeon_game.dart';
import '../game/overlays/game_over_overlay.dart';
import '../game/overlays/hud_overlay.dart';
import '../game/overlays/level_up_overlay.dart';
import '../game/overlays/pause_overlay.dart';

class GameScreen extends StatefulWidget {
  final GameRepository repository;
  final List<PermanentUpgrade> upgrades;
  final bool isLeftHanded;
  final String difficultyMode;

  const GameScreen({
    super.key,
    required this.repository,
    required this.upgrades,
    this.isLeftHanded = false,
    this.difficultyMode = 'nightmare',
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DungeonGame game;
  int _gameKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    game = DungeonGame(
      repository: widget.repository,
      activeUpgrades: widget.upgrades,
      isLeftHanded: widget.isLeftHanded,
      difficultyMode: widget.difficultyMode,
    );
  }

  void _restartGame() {
    setState(() {
      _gameKeyCounter++;
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      body: GameWidget<DungeonGame>(
        key: ValueKey(_gameKeyCounter),
        game: game,
        initialActiveOverlays: const ['HUD'],
        overlayBuilderMap: {
          'HUD': (context, game) => HudOverlay(game: game),
          'LevelUp': (context, game) => LevelUpOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(
                game: game,
                onReturnToMenu: () => Navigator.of(context).pop(),
                onRestart: _restartGame,
              ),
          'Pause': (context, game) => PauseOverlay(
                game: game,
                onResume: () {
                  game.overlays.remove('Pause');
                  game.resumeEngine();
                  AudioManager.resumeBgm();
                },
                onQuit: () {
                  game.overlays.remove('Pause');
                  AudioManager.pauseBgm();
                  Navigator.of(context).pop();
                },
              ),
        },
      ),
    );
  }
}
