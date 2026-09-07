import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/audio_manager.dart';
import '../core/log_manager.dart';
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
  final String gameMode; // 'journey' or 'survivor'
  final int? targetDurationSeconds; // 180, 300, 600, or null for endless
  final int journeyStage; // current stage (1, 2, 3, 4...)

  bool get isNightmare => difficultyMode == 'nightmare';
  bool get isBossMatch => targetDurationSeconds == 600 || (gameMode == 'journey' && journeyStage % 4 == 0);
  int get chapter => ((journeyStage - 1) ~/ 4) + 1;

  late PlayerComponent player;
  late JoystickComponent joystick;

  // Pools controlados para máximo rendimiento
  final List<EnemyComponent> activeEnemies = [];
  final List<GemComponent> activeGems = [];
  int get currentMaxEnemies {
    // Si hay un Jefe activo, la cantidad de esbirros se modula según la dificultad del jefe
    final bossList = activeEnemies.where((e) => e.isBoss).toList();
    if (bossList.isNotEmpty) {
      final b = bossList.first;
      switch (b.type) {
        case EnemyType.bossIgnis:
          // Jefe coloso sencillo: enjambre de esbirros secundario controlado
          return isNightmare ? 55 : 35;
        case EnemyType.bossGorgoroth:
        case EnemyType.bossVespertina:
          return isNightmare ? 45 : 28;
        case EnemyType.bossValerius:
          // Jefe mago táctico: guardia reducida
          return isNightmare ? 28 : 16;
        case EnemyType.bossXulkrag:
          // Jefe abisal supremo: esbirros mínimos para favorecer duelo 1v1
          return isNightmare ? 14 : 10;
        case EnemyType.boss:
        default:
          return isNightmare ? 50 : 25;
      }
    }
    if (!isNightmare) return 32;
    if (currentWave == 1) return 50;
    if (currentWave == 2) return 65;
    return (65 + (currentWave - 2) * 5).clamp(65, 80);
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
  final ValueNotifier<Color> bossAuraColorNotifier = ValueNotifier(const Color(0xFFFF1744));
  final ValueNotifier<double> bossHpNotifier = ValueNotifier(1.0);

  // Notificadores para la Habilidad Definitiva (Ultimate)
  final ValueNotifier<double> ultimateChargeNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> isUltimateReadyNotifier = ValueNotifier(false);

  // Notificadores de Victoria
  bool _isVictoryTriggered = false;
  final ValueNotifier<bool> isVictoryNotifier = ValueNotifier(false);
  int victoryBonusGold = 0;

  // Estadísticas de la partida en curso
  int score = 0;
  int enemiesSlain = 0;
  int goldEarned = 0;
  double elapsedTime = 0;
  int currentWave = 1;

  // Temporizador de generación de enemigos y heartbeat de diagnóstico
  double _spawnTimer = 0;
  double _spawnInterval = 2.0;
  double _heartbeatTimer = 0;

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
    this.gameMode = 'journey',
    this.targetDurationSeconds,
    this.journeyStage = 1,
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

    // Heartbeat diagnóstico cada 10 segundos en combate activo
    _heartbeatTimer += dt;
    if (_heartbeatTimer >= 10.0) {
      _heartbeatTimer = 0;
      LogManager.log(
        'DungeonGame [Heartbeat]: Tiempo: ${elapsedTime.toInt()}s | Oleada: $currentWave | '
        'Enemigos: ${activeEnemies.length}/$currentMaxEnemies | Gemas: ${activeGems.length} | '
        'HP: ${player.hp.toInt()}/${player.maxHp.toInt()}',
      );
    }

    // Condición de Victoria en Modo Viaje:
    if (gameMode == 'journey' && !_isVictoryTriggered && targetDurationSeconds != null) {
      if (targetDurationSeconds! < 600) {
        // Escaramuzas de 3 o 5 minutos: victoria épica al completar el tiempo
        if (elapsedTime >= targetDurationSeconds!) {
          triggerVictory();
          return;
        }
      } else {
        // Partida de Jefe de 10 minutos (600 s):
        // Al minuto 8:00 (480 s), desatar el encuentro del Jefe Legendario del Capítulo
        if (elapsedTime >= 480 && !_spawnedBossWaves.contains(999)) {
          _spawnedBossWaves.add(999);
          _spawnBossEncounter();
        }
      }
    }

    // Dificultad progresiva por oleadas (cada 45 segundos sube de oleada)
    final newWave = (elapsedTime / 45).floor() + 1;
    if (newWave != currentWave) {
      currentWave = newWave;
      LogManager.log('DungeonGame: ¡Comienza Oleada $currentWave a los ${elapsedTime.toInt()}s!');
    }

    // Aceleración adaptativa de spawn para mantener los simultáneos requeridos
    final targetPopulation = !isNightmare
        ? (currentWave == 1 ? 20 : (currentWave == 2 ? 28 : 32))
        : (currentWave == 1 ? 45 : (currentWave == 2 ? 60 : 75));
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

  EnemyComponent _createBoss(int bossNumber, Vector2 position, double difficultyMultiplier) {
    final bossIndex = (bossNumber - 1) % 6;
    switch (bossIndex) {
      case 0:
        return EnemyComponent.bossIgnis(position, difficultyMultiplier, bossSprite, isNightmare: isNightmare);
      case 1:
        return EnemyComponent.bossGorgoroth(position, difficultyMultiplier, bossSprite, isNightmare: isNightmare);
      case 2:
        return EnemyComponent.bossVespertina(position, difficultyMultiplier, bossSprite, isNightmare: isNightmare);
      case 3:
        return EnemyComponent.bossValerius(position, difficultyMultiplier, bossSprite, isNightmare: isNightmare);
      case 4:
        return EnemyComponent.bossXulkrag(position, difficultyMultiplier, bossSprite, isNightmare: isNightmare);
      case 5:
      default:
        return EnemyComponent.boss(position, difficultyMultiplier, bossSprite, isNightmare: isNightmare);
    }
  }

  void _spawnBossEncounter({int bossCount = 1, int? customBossNumber}) {
    final bossNumber = customBossNumber ?? chapter;
    final bossDifficultyMultiplier = 1.0 + (currentWave - 1) * (isNightmare ? 0.16 : 0.10);
    LogManager.log('DungeonGame: ¡Invocando Jefe (Tipo #$bossNumber, cantidad: $bossCount) en oleada $currentWave!');
    for (int i = 0; i < bossCount; i++) {
      final angle = (2 * pi / bossCount) * i + _random.nextDouble() * 0.3;
      const spawnDistance = 560.0;
      final pos = player.position + Vector2(cos(angle), sin(angle)) * spawnDistance;
      pos.x = pos.x.clamp(60.0, DungeonMapComponent.mapWidth - 60.0);
      pos.y = pos.y.clamp(60.0, DungeonMapComponent.mapHeight - 60.0);
      world.add(_createBoss(bossNumber, pos, bossDifficultyMultiplier));
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
    // Modo Supervivencia: Invocación de Jefes cíclicos cada 5 oleadas
    if (gameMode == 'survivor') {
      if (currentWave >= 5 && currentWave % 5 == 0 && !_spawnedBossWaves.contains(currentWave)) {
        _spawnedBossWaves.add(currentWave);
        final bossCount = getBossCountForWave(currentWave);
        final bossNumber = (currentWave ~/ 5);
        _spawnBossEncounter(bossCount: bossCount, customBossNumber: bossNumber);
        return;
      }
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
        default:
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

    final enemiesSnapshot = List<EnemyComponent>.from(activeEnemies);
    for (final e in enemiesSnapshot) {
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
        default:
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
        targetBats = 24;
        targetSkeletons = 16;
        targetBrutes = 5;
      } else if (currentWave == 2) {
        targetBats = 32;
        targetSkeletons = 20;
        targetBrutes = 8;
      } else {
        // Oleada 3+: Escala equilibrada incorporando Magos Cultistas y Duendes Bomba
        final waveBonus = (currentWave - 3);
        targetBats = (26 + waveBonus).clamp(20, 30);
        targetSkeletons = (18 + waveBonus).clamp(14, 22);
        targetBrutes = (6 + (waveBonus ~/ 2)).clamp(4, 8);
        targetCultists = (12 + waveBonus).clamp(8, 14);
        targetBombers = (12 + waveBonus).clamp(8, 14);
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
      final oldest = activeGems.removeAt(0);
      oldest.removeFromParent();
    }
    world.add(GemComponent(position: pos, type: type, value: value));
  }

  void onEnemyKilled(EnemyComponent enemy) {
    if (enemy.isBoss) {
      LogManager.log('DungeonGame: ¡${enemy.bossDisplayName} ha sido derrotado en oleada $currentWave!');
      if (gameMode == 'journey' && isBossMatch) {
        // Victoria si ya no quedan otros jefes vivos en la arena
        final remainingBosses = activeEnemies.where((e) => e.isBoss && e != enemy).length;
        if (remainingBosses == 0) {
          triggerVictory();
        }
      }
    }
    enemiesSlain++;
    killsNotifier.value = enemiesSlain;
    score += (enemy.expValue * currentWave);
    player.onEnemyKilled();
  }

  void updateBossHud() {
    final bosses = activeEnemies.where((e) => e.isBoss).toList();
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
      bossAuraColorNotifier.value = bosses.first.bossAuraColor;
      if (bosses.length == 1) {
        bossNameNotifier.value = bosses.first.bossDisplayName;
      } else {
        bossNameNotifier.value = '${bosses.first.bossDisplayName} x${bosses.length}';
      }
    }
  }

  void triggerVictory() {
    if (_isVictoryTriggered || !player.isAlive) return;
    _isVictoryTriggered = true;
    isVictoryNotifier.value = true;
    LogManager.log('DungeonGame: ¡¡¡VICTORIA ALCANZADA!!! Tiempo final: ${elapsedTime.toInt()}s. Guardando partida...');

    if (targetDurationSeconds == 180) {
      victoryBonusGold = 250;
    } else if (targetDurationSeconds == 300) {
      victoryBonusGold = 450;
    } else if (targetDurationSeconds == 600) {
      victoryBonusGold = 1200;
    } else {
      victoryBonusGold = 350;
    }

    addGold(victoryBonusGold);
    AudioManager.playLevelUp();
    pauseEngine();
    saveCurrentRun(isVictory: true);

    overlays.add('Victory');
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
    LogManager.log('DungeonGame: Subida de nivel encolada (Nivel $level, pendientes: $pendingLevelUps)');
    playerLevelNotifier.value = level;
    if (!overlays.isActive('LevelUp')) {
      AudioManager.playLevelUp();
      pauseEngine();
      overlays.add('LevelUp');
    }
  }

  void applySkillUpgrade(String skillType) {
    LogManager.log('DungeonGame: Aplicando mejora $skillType (pendientes antes: $pendingLevelUps)');
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
    if (pendingLevelUps <= 0) {
      pendingLevelUps = 0;
      overlays.remove('LevelUp');
      resumeEngine();
      LogManager.log('DungeonGame: Todas las mejoras aplicadas. Motor reanudado.');
    } else {
      LogManager.log('DungeonGame: Quedan $pendingLevelUps mejoras pendientes por elegir.');
    }
  }

  bool _runResultSaved = false;

  void saveCurrentRun({bool isVictory = false}) {
    if (_runResultSaved) return;
    _runResultSaved = true;
    repository.saveRunResult(
      score: score,
      survivedSeconds: elapsedTime.toInt(),
      enemiesSlain: enemiesSlain,
      goldEarned: goldEarned,
      waveReached: currentWave,
      isVictory: isVictory && gameMode == 'journey',
    );
  }

  void onGameOver() {
    LogManager.log('DungeonGame: ¡¡¡GAME OVER!!! Héroe caído a los ${elapsedTime.toInt()}s (Oleada $currentWave). Guardando...');
    AudioManager.pauseBgm();
    AudioManager.playGameOver();
    pauseEngine();
    saveCurrentRun(isVictory: false);

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
