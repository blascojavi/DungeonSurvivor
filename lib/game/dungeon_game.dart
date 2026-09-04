import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/database/database.dart';
import '../data/repositories/game_repository.dart';
import 'components/dungeon_map_component.dart';
import 'components/enemy_component.dart';
import 'components/player_component.dart';

class DungeonGame extends FlameGame with HasCollisionDetection, KeyboardEvents {
  final GameRepository repository;
  final List<PermanentUpgrade> activeUpgrades;

  late PlayerComponent player;
  late JoystickComponent joystick;

  // Estadísticas de la partida en curso
  int score = 0;
  int enemiesSlain = 0;
  int goldEarned = 0;
  double elapsedTime = 0;
  int currentWave = 1;

  // Temporizador de generación de enemigos
  double _spawnTimer = 0;
  double _spawnInterval = 2.0;

  // Notificadores reactivos para los Overlays de Flutter
  final ValueNotifier<double> playerHpNotifier = ValueNotifier(100);
  final ValueNotifier<double> playerMaxHpNotifier = ValueNotifier(100);
  final ValueNotifier<double> expProgressNotifier = ValueNotifier(0.0);
  final ValueNotifier<int> playerLevelNotifier = ValueNotifier(1);
  final ValueNotifier<int> goldNotifier = ValueNotifier(0);
  final ValueNotifier<int> killsNotifier = ValueNotifier(0);
  final ValueNotifier<int> timeSecondsNotifier = ValueNotifier(0);

  final bool isLeftHanded;

  DungeonGame({
    required this.repository,
    required this.activeUpgrades,
    this.isLeftHanded = false,
  });

  @override
  Color backgroundColor() => const Color(0xFF0A0D14);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Añadir el mapa de la mazmorra al mundo
    world.add(DungeonMapComponent());

    // 2. Calcular bonus de mejoras permanentes desde la BBDD local
    double bonusHp = 0;
    double bonusAttack = 0;
    double bonusSpeed = 0;
    double bonusMagnet = 0;

    for (final upgrade in activeUpgrades) {
      if (upgrade.currentLevel > 0) {
        final totalBonus = upgrade.currentLevel * upgrade.bonusPerLevel;
        switch (upgrade.upgradeId) {
          case 'max_hp':
            bonusHp = totalBonus;
            break;
          case 'attack_power':
            bonusAttack = totalBonus;
            break;
          case 'move_speed':
            bonusSpeed = totalBonus;
            break;
          case 'magnet_radius':
            bonusMagnet = totalBonus;
            break;
        }
      }
    }

    // 3. Crear al jugador con estadísticas calculadas
    final initialMaxHp = 100 * (1 + bonusHp);
    player = PlayerComponent(
      position: Vector2(DungeonMapComponent.mapWidth / 2, DungeonMapComponent.mapHeight / 2),
      maxHp: initialMaxHp,
      speed: 180 * (1 + bonusSpeed),
      magnetRadius: 120 * (1 + bonusMagnet),
      bulletDamage: 25 * (1 + bonusAttack),
      attackInterval: 0.5,
    );
    world.add(player);

    playerHpNotifier.value = player.hp;
    playerMaxHpNotifier.value = player.maxHp;

    // 4. Configurar cámara para seguir suavemente al héroe
    camera.follow(player);

    // 5. Crear Joystick Táctil en la interfaz de pantalla
    final knobPaint = Paint()..color = const Color(0xCC00E5FF);
    final backgroundPaint = Paint()..color = const Color(0x441E2638);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 26, paint: knobPaint),
      background: CircleComponent(radius: 65, paint: backgroundPaint),
      margin: isLeftHanded
          ? const EdgeInsets.only(right: 40, bottom: 40)
          : const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!player.isAlive || paused) return;

    // Actualizar movimiento del jugador desde el joystick
    if (!joystick.delta.isZero()) {
      player.moveDirection = joystick.relativeDelta;
    }

    // Temporizador de supervivencia
    elapsedTime += dt;
    timeSecondsNotifier.value = elapsedTime.toInt();

    // Dificultad progresiva por oleadas (cada 45 segundos sube de oleada)
    currentWave = (elapsedTime / 45).floor() + 1;
    _spawnInterval = (2.0 - (currentWave * 0.15)).clamp(0.4, 2.0);

    // Generador de oleadas de enemigos
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnEnemyWave();
    }
  }

  void _spawnEnemyWave() {
    final rand = Random();
    // Generar enemigos en los bordes visibles alrededor del jugador
    final angle = rand.nextDouble() * 2 * pi;
    const spawnDistance = 550.0;
    final spawnPos = player.position + Vector2(cos(angle), sin(angle)) * spawnDistance;

    // Evitar generar fuera del mapa
    spawnPos.x = spawnPos.x.clamp(50.0, DungeonMapComponent.mapWidth - 50.0);
    spawnPos.y = spawnPos.y.clamp(50.0, DungeonMapComponent.mapHeight - 50.0);

    final difficultyMultiplier = 1.0 + (currentWave - 1) * 0.25;

    final roll = rand.nextInt(100);
    if (roll < 55) {
      // 55% Murciélago veloz
      world.add(EnemyComponent.bat(spawnPos, difficultyMultiplier));
    } else if (roll < 85) {
      // 30% Esqueleto estándar
      world.add(EnemyComponent.skeleton(spawnPos, difficultyMultiplier));
    } else {
      // 15% Bruto resistente
      world.add(EnemyComponent.brute(spawnPos, difficultyMultiplier));
    }
  }

  void onEnemyKilled(EnemyComponent enemy) {
    enemiesSlain++;
    score += (enemy.expValue * currentWave);
    killsNotifier.value = enemiesSlain;
  }

  void addGold(int amount) {
    goldEarned += amount;
    goldNotifier.value = goldEarned;
  }

  void onPlayerHealthChanged(double hp, double maxHp) {
    playerHpNotifier.value = hp;
    playerMaxHpNotifier.value = maxHp;
  }

  void onPlayerExpChanged(int exp, int nextExp, int level) {
    expProgressNotifier.value = (exp / nextExp).clamp(0.0, 1.0);
    playerLevelNotifier.value = level;
  }

  void onPlayerLevelUp(int level) {
    pauseEngine();
    overlays.add('LevelUp');
  }

  void applySkillUpgrade(String skillType) {
    switch (skillType) {
      case 'damage':
        player.bulletDamage *= 1.25; // +25% daño
        break;
      case 'fire_rate':
        player.attackInterval = (player.attackInterval * 0.82).clamp(0.12, 1.0); // +18% cadencia
        break;
      case 'speed':
        player.speed *= 1.15; // +15% velocidad
        break;
      case 'heal_and_health':
        player.maxHp += 25;
        player.heal(player.maxHp * 0.5); // Cura el 50% de la vida y añade vida máxima
        break;
      case 'magnet':
        player.magnetRadius *= 1.4; // +40% imán
        break;
    }
    overlays.remove('LevelUp');
    resumeEngine();
  }

  void onGameOver() {
    pauseEngine();
    // Guardar partida en la base de datos local SQLite de forma atómica y asíncrona
    repository.saveRunResult(
      score: score,
      survivedSeconds: elapsedTime.toInt(),
      enemiesSlain: enemiesSlain,
      goldEarned: goldEarned,
      waveReached: currentWave,
    );

    overlays.add('GameOver');
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    Vector2 dir = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      dir.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      dir.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      dir.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      dir.x += 1;
    }

    if (isKeyDown && !dir.isZero()) {
      player.moveDirection = dir.normalized();
    } else if (keysPressed.isEmpty && joystick.delta.isZero()) {
      player.moveDirection = Vector2.zero();
    }

    return KeyEventResult.handled;
  }
}
