import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/audio_manager.dart';
import '../data/database/database.dart';
import '../data/repositories/game_repository.dart';
import 'components/dungeon_map_component.dart';
import 'components/enemy_component.dart';
import 'components/gem_component.dart';
import 'components/player_component.dart';

class DungeonGame extends FlameGame with HasCollisionDetection, KeyboardEvents {
  final GameRepository repository;
  final List<PermanentUpgrade> activeUpgrades;
  final bool isLeftHanded;
  final String difficultyMode;

  bool get isNightmare => difficultyMode == 'nightmare';

  late PlayerComponent player;
  late JoystickComponent joystick;

  // Pools controlados para máximo rendimiento
  final List<EnemyComponent> activeEnemies = [];
  final List<GemComponent> activeGems = [];
  int get currentMaxEnemies {
    if (!isNightmare) return 32;
    if (currentWave == 1) return 70; // Mayor que 60 en Pesadilla
    if (currentWave == 2) return 95;
    return (95 + (currentWave - 2) * 8).clamp(95, 125);
  }
  static const int maxGems = 64;
  static final Random _random = Random();

  // Sprites cacheados en memoria para no decodificar imágenes en caliente
  Sprite? batSprite;
  Sprite? skeletonSprite;
  Sprite? bruteSprite;
  Sprite? cultistSprite;
  Sprite? bomberSprite;
  Sprite? bossSprite;

  // Cola de niveles pendientes para evitar bloqueos del Overlay al ganar mucha EXP
  int pendingLevelUps = 0;

  // Registro de oleadas de Jefes ya generadas
  final Set<int> _spawnedBossWaves = {};

  int getBossCountForWave(int wave) {
    if (wave < 5 || wave % 5 != 0) return 0;
    if (!isNightmare) return 1; // En Modo Novato siempre es un único jefe
    if (wave < 15) return 1; // En Modo Pesadilla: Oleadas 5 y 10: 1 jefe
    // A partir de la oleada 15, en cada oleada posterior multiplica x2:
    // Oleada 15 = 2, Oleada 20 = 4, Oleada 25 = 8, Oleada 30 = 16...
    final stepsAfter15 = ((wave - 15) / 5).floor();
    return (2 * pow(2, stepsAfter15)).toInt();
  }

  final ValueNotifier<bool> isBossAliveNotifier = ValueNotifier(false);
  final ValueNotifier<String> bossNameNotifier = ValueNotifier('LORD MALAKOR - SEÑOR DEL ABISMO');
  final ValueNotifier<double> bossHpNotifier = ValueNotifier(1.0);

  // Notificadores para la Habilidad Definitiva (Ultimate)
  final ValueNotifier<double> ultimateChargeNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> isUltimateReadyNotifier = ValueNotifier(false);

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

  DungeonGame({
    required this.repository,
    required this.activeUpgrades,
    this.isLeftHanded = false,
    this.difficultyMode = 'nightmare',
  });

  @override
  Color backgroundColor() => const Color(0xFF0A0D14);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Precarga e inicio de audio BGM y efectos
    await AudioManager.initialize();
    await AudioManager.startBgm();

    // Precarga de sprites de enemigos y jefes una sola vez
    try {
      batSprite = await loadSprite('bat.png');
      skeletonSprite = await loadSprite('skeleton.png');
      bruteSprite = await loadSprite('brute.png');
      cultistSprite = await loadSprite('cultist.png');
      bomberSprite = await loadSprite('bomber.png');
      bossSprite = await loadSprite('boss.png');
    } catch (_) {}

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

    // 5. Crear Joystick Táctil con margen adaptable zurdo/diestro
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

    // Aceleración adaptativa de spawn para mantener los simultáneos requeridos
    final targetPopulation = currentWave == 1 ? 57 : (currentWave == 2 ? 85 : 105);
    if (activeEnemies.length < targetPopulation * 0.75) {
      _spawnInterval = 0.22; // Inundación rápida hasta llenar la arena
    } else {
      _spawnInterval = 0.65; // Mantenimiento sostenido
    }

    // Generador de oleadas de enemigos
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnEnemyWave();
    }
  }

  Vector2 getRandomSpawnPosition() {
    final angle = _random.nextDouble() * 2 * pi;
    const spawnDistance = 540.0;
    final pos = player.position + Vector2(cos(angle), sin(angle)) * spawnDistance;
    pos.x = pos.x.clamp(60.0, DungeonMapComponent.mapWidth - 60.0);
    pos.y = pos.y.clamp(60.0, DungeonMapComponent.mapHeight - 60.0);
    return pos;
  }

  void _spawnEnemyWave() {
    // Invocación del Jefe de Mazmorra en Oleadas múltiples de 5 (5, 10, 15, 20, 25...)
    // A partir de la oleada 15, cada oleada de jefe posterior multiplica los jefes Malakor x2
    if (currentWave >= 5 && currentWave % 5 == 0 && !_spawnedBossWaves.contains(currentWave)) {
      _spawnedBossWaves.add(currentWave);
      final bossCount = getBossCountForWave(currentWave);
      final bossDifficultyMultiplier = 1.0 + (currentWave - 1) * 0.12;
      for (int i = 0; i < bossCount; i++) {
        final angle = (2 * pi / bossCount) * i + _random.nextDouble() * 0.3;
        const spawnDistance = 560.0;
        final pos = player.position + Vector2(cos(angle), sin(angle)) * spawnDistance;
        pos.x = pos.x.clamp(60.0, DungeonMapComponent.mapWidth - 60.0);
        pos.y = pos.y.clamp(60.0, DungeonMapComponent.mapHeight - 60.0);
        world.add(EnemyComponent.boss(pos, bossDifficultyMultiplier, bossSprite, isNightmare: isNightmare));
      }
      return;
    }

    if (activeEnemies.length >= currentMaxEnemies) {
      return; // Límite dinámico de entidades para asegurar 60/120 FPS sin saturar
    }

    // Generación por lote si hay déficit grande para alcanzar rápido los simultáneos (solo en Pesadilla)
    final batchCount = (!isNightmare) ? 1 : ((activeEnemies.length < currentMaxEnemies - 15) ? 2 : 1);
    final difficultyMultiplier = 1.0 + (currentWave - 1) * (isNightmare ? 0.18 : 0.12);

    for (int b = 0; b < batchCount; b++) {
      if (activeEnemies.length >= currentMaxEnemies) break;
      final spawnPos = getRandomSpawnPosition();
      final typeToSpawn = _selectNextEnemyType();
      EnemyComponent enemy;
      switch (typeToSpawn) {
        case EnemyType.bat:
          enemy = EnemyComponent.bat(spawnPos, difficultyMultiplier, batSprite, isNightmare: isNightmare);
          break;
        case EnemyType.skeleton:
          enemy = EnemyComponent.skeleton(spawnPos, difficultyMultiplier, skeletonSprite, isNightmare: isNightmare);
          break;
        case EnemyType.brute:
          enemy = EnemyComponent.brute(spawnPos, difficultyMultiplier, bruteSprite, isNightmare: isNightmare);
          break;
        case EnemyType.cultist:
          enemy = EnemyComponent.cultist(spawnPos, difficultyMultiplier, cultistSprite, isNightmare: isNightmare);
          break;
        case EnemyType.bomber:
          enemy = EnemyComponent.bomber(spawnPos, difficultyMultiplier, bomberSprite, isNightmare: isNightmare);
          break;
        case EnemyType.boss:
          enemy = EnemyComponent.bat(spawnPos, difficultyMultiplier, batSprite, isNightmare: isNightmare);
          break;
      }
      world.add(enemy);
    }
  }

  EnemyType _selectNextEnemyType() {
    int bats = 0;
    int skeletons = 0;
    int brutes = 0;
    int cultists = 0;
    int bombers = 0;

    for (final e in activeEnemies) {
      switch (e.type) {
        case EnemyType.bat:
          bats++;
          break;
        case EnemyType.skeleton:
          skeletons++;
          break;
        case EnemyType.brute:
          brutes++;
          break;
        case EnemyType.cultist:
          cultists++;
          break;
        case EnemyType.bomber:
          bombers++;
          break;
        case EnemyType.boss:
          break;
      }
    }

    int targetBats;
    int targetSkeletons;
    int targetBrutes;
    int targetCultists = 0;
    int targetBombers = 0;

    if (!isNightmare) {
      // Modo Novato: distribución equilibrada y clásica de hordas
      if (currentWave == 1) {
        targetBats = 12;
        targetSkeletons = 6;
        targetBrutes = 2;
      } else if (currentWave == 2) {
        targetBats = 16;
        targetSkeletons = 9;
        targetBrutes = 3;
      } else {
        final waveBonus = (currentWave - 3);
        targetBats = (15 + waveBonus).clamp(12, 18);
        targetSkeletons = (10 + waveBonus).clamp(8, 14);
        targetBrutes = (3 + (waveBonus ~/ 2)).clamp(2, 5);
        targetCultists = (4 + waveBonus).clamp(3, 8);
        targetBombers = (4 + waveBonus).clamp(3, 7);
      }
    } else {
      // Modo Pesadilla: hordas brutales masivas
      if (currentWave == 1) {
        // Murciélagos: 25 a 35 (centro 30)
        // Esqueletos: 15 a 25 (centro 20)
        // Brutos: 5 a 9 (centro 7)
        targetBats = 30;
        targetSkeletons = 20;
        targetBrutes = 7;
      } else if (currentWave == 2) {
        // Aumenta un 50% los simultáneos de cada uno
        targetBats = 45; // 30 * 1.5
        targetSkeletons = 30; // 20 * 1.5
        targetBrutes = 10; // 7 * 1.5 ≈ 10
      } else {
        // Oleada 3+: Escala incorporando Magos Cultistas y Duendes Bomba
        final waveBonus = (currentWave - 3) * 2;
        targetBats = (38 + waveBonus).clamp(25, 45);
        targetSkeletons = (25 + waveBonus).clamp(18, 32);
        targetBrutes = (9 + (waveBonus ~/ 2)).clamp(6, 12);
        targetCultists = (15 + waveBonus).clamp(10, 22);
        targetBombers = (14 + waveBonus).clamp(10, 20);
      }
    }

    final deficits = <EnemyType, int>{
      EnemyType.bat: targetBats - bats,
      EnemyType.skeleton: targetSkeletons - skeletons,
      EnemyType.brute: targetBrutes - brutes,
    };
    if (currentWave >= 3) {
      deficits[EnemyType.cultist] = targetCultists - cultists;
      deficits[EnemyType.bomber] = targetBombers - bombers;
    }

    EnemyType bestType = EnemyType.bat;
    int maxDeficit = -9999;
    for (final entry in deficits.entries) {
      if (entry.value > maxDeficit) {
        maxDeficit = entry.value;
        bestType = entry.key;
      }
    }
    return bestType;
  }

  void spawnGem(Vector2 pos, GemType type, int value) {
    if (activeGems.length >= maxGems && activeGems.isNotEmpty) {
      final oldest = activeGems.first;
      oldest.removeFromParent();
    }
    world.add(GemComponent(position: pos, type: type, value: value));
  }

  void onEnemyKilled(EnemyComponent enemy) {
    enemiesSlain++;
    killsNotifier.value = enemiesSlain;
    score += (enemy.expValue * currentWave);
    player.onEnemyKilled();
  }

  void updateBossHud() {
    final bosses = activeEnemies.where((e) => e.type == EnemyType.boss).toList();
    if (bosses.isEmpty) {
      isBossAliveNotifier.value = false;
      bossHpNotifier.value = 0.0;
    } else {
      isBossAliveNotifier.value = true;
      double currentHp = 0;
      double totalMax = 0;
      for (final b in bosses) {
        currentHp += b.hp;
        totalMax += b.maxHp;
      }
      bossHpNotifier.value = (currentHp / totalMax).clamp(0.0, 1.0);
      if (bosses.length == 1) {
        bossNameNotifier.value = 'LORD MALAKOR - SEÑOR DEL ABISMO';
      } else {
        bossNameNotifier.value = 'LORD MALAKOR x${bosses.length} - SEÑORES DEL ABISMO';
      }
    }
  }

  void onUltimateChargeChanged(double ratio) {
    ultimateChargeNotifier.value = ratio;
    isUltimateReadyNotifier.value = ratio >= 1.0;
  }

  void triggerPlayerUltimate() {
    player.triggerUltimate();
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

  void queuePlayerLevelUp(int level) {
    pendingLevelUps++;
    playerLevelNotifier.value = level;
    if (!overlays.isActive('LevelUp')) {
      AudioManager.playLevelUp();
      pauseEngine();
      overlays.add('LevelUp');
    }
  }

  void applySkillUpgrade(String skillType) {
    switch (skillType) {
      case 'damage':
        player.bulletDamage *= 1.25;
        break;
      case 'fire_rate':
        player.attackInterval = (player.attackInterval * 0.82).clamp(0.12, 1.0);
        break;
      case 'speed':
        player.speed *= 1.15;
        break;
      case 'heal_and_health':
        player.maxHp += 25;
        player.heal(player.maxHp * 0.5);
        break;
      case 'magnet':
        player.magnetRadius *= 1.4;
        break;
    }

    pendingLevelUps--;
    if (pendingLevelUps > 0) {
      // Recrear el overlay limpiamente para el siguiente nivel pendiente sin congelar el juego
      overlays.remove('LevelUp');
      Future.microtask(() {
        if (pendingLevelUps > 0 && isMounted) {
          overlays.add('LevelUp');
        }
      });
    } else {
      pendingLevelUps = 0;
      overlays.remove('LevelUp');
      resumeEngine();
    }
  }

  bool _runResultSaved = false;

  void saveCurrentRun() {
    if (_runResultSaved) return;
    _runResultSaved = true;
    repository.saveRunResult(
      score: score,
      survivedSeconds: elapsedTime.toInt(),
      enemiesSlain: enemiesSlain,
      goldEarned: goldEarned,
      waveReached: currentWave,
    );
  }

  void onGameOver() {
    AudioManager.pauseBgm();
    AudioManager.playGameOver();
    pauseEngine();
    saveCurrentRun();

    overlays.add('GameOver');
  }

  @override
  void onRemove() {
    AudioManager.pauseBgm();
    super.onRemove();
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
