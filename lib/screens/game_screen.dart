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
import '../game/overlays/victory_overlay.dart';

class GameScreen extends StatefulWidget {
  final GameRepository repository;
  final List<PermanentUpgrade> upgrades;
  final bool isLeftHanded;
  final String difficultyMode;
  final String gameMode;
  final int? targetDurationSeconds;
  final int journeyStage;

  const GameScreen({
    super.key,
    required this.repository,
    required this.upgrades,
    this.isLeftHanded = false,
    this.difficultyMode = 'nightmare',
    this.gameMode = 'journey',
    this.targetDurationSeconds,
    this.journeyStage = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late DungeonGame game;
  int _gameKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pausar automáticamente si se bloquea la pantalla, se pulsa el botón redondo o se sale al menú
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pauseGame();
    }
  }

  void _initGame() {
    game = DungeonGame(
      repository: widget.repository,
      activeUpgrades: widget.upgrades,
      isLeftHanded: widget.isLeftHanded,
      difficultyMode: widget.difficultyMode,
      gameMode: widget.gameMode,
      targetDurationSeconds: widget.targetDurationSeconds,
      journeyStage: widget.journeyStage,
    );
  }

  void _restartGame() {
    setState(() {
      _gameKeyCounter++;
      _initGame();
    });
  }

  void _pauseGame() {
    if (!mounted) return;
    // Si no está en fin de partida o victoria, congelar el motor y mostrar pausa
    if (!game.overlays.isActive('GameOver') && !game.overlays.isActive('Victory')) {
      if (!game.paused) {
        game.pauseEngine();
      }
      AudioManager.pauseBgm();
      if (!game.overlays.isActive('Pause')) {
        game.overlays.add('Pause');
      }
    } else {
      AudioManager.pauseBgm();
    }
  }

  void _handleBackPress() {
    // 1. Si la partida ya finalizó (GameOver o Victory), permitir salir directamente
    if (game.overlays.isActive('GameOver') || game.overlays.isActive('Victory')) {
      Navigator.of(context).pop();
      return;
    }

    // 2. Si la partida está activa, pausar el juego inmediatamente en vez de perder el progreso
    if (!game.overlays.isActive('Pause')) {
      _pauseGame();
      return;
    }

    // 3. Si ya está en la pantalla de pausa y pulsa atrás, confirmar si realmente desea salir
    _showExitConfirmationDialog();
  }

  Future<void> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD700), size: 26),
            SizedBox(width: 10),
            Text(
              '¿ABANDONAR PARTIDA?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        content: const Text(
          'Si sales ahora, se guardarán en tu perfil de SQLite el oro, las bajas y la puntuación obtenidas hasta este momento.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CONTINUAR JUGANDO',
              style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2A4B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'SALIR AL MENÚ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      game.overlays.remove('Pause');
      game.saveCurrentRun();
      AudioManager.pauseBgm();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
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
            'Victory': (context, game) => VictoryOverlay(
                  game: game,
                  onNextStage: () async {
                    game.overlays.remove('Victory');
                    final nextStage = widget.journeyStage + 1;
                    final cyclePos = ((nextStage - 1) % 4) + 1;
                    final duration = cyclePos == 4 ? 600 : (cyclePos % 2 == 1 ? 180 : 300);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            repository: widget.repository,
                            upgrades: widget.upgrades,
                            isLeftHanded: widget.isLeftHanded,
                            difficultyMode: widget.difficultyMode,
                            gameMode: 'journey',
                            journeyStage: nextStage,
                            targetDurationSeconds: duration,
                          ),
                        ),
                      );
                    }
                  },
                  onReturnToMenu: () => Navigator.of(context).pop(),
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
                    game.saveCurrentRun();
                    AudioManager.pauseBgm();
                    Navigator.of(context).pop();
                  },
                ),
          },
        ),
      ),
    );
  }
}
