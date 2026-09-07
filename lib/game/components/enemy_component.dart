import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/log_manager.dart';
import 'enemy_bullet_component.dart';
import 'explosion_component.dart';
import 'gem_component.dart';
import 'player_component.dart';
import '../dungeon_game.dart';

enum EnemyType {
  bat,
  skeleton,
  brute,
  cultist,
  bomber,
  boss, // Lord Malakor
  bossIgnis, // Coloso de Ceniza
  bossGorgoroth, // Titán de Hueso
  bossVespertina, // Matriarca del Enjambre
  bossValerius, // Archimago Hereje
  bossXulkrag, // Devorador de Sombras
}

class EnemyComponent extends PositionComponent with CollisionCallbacks, HasGameReference<DungeonGame> {
  final EnemyType type;
  final bool isNightmare;
  double hp;
  final double maxHp;
  final double speed;
  final double contactDamage;
  final int expValue;
  final int goldChance;

  double _flashTimer = 0;
  double _attackCooldown = 0;
  double _specialTimer = 0;
  final Sprite? sprite;
  double _facingDirection = 1.0;
  bool _isDead = false;
  bool get isDead => _isDead;
  late final CircleHitbox _hitbox;

  // Variables para IA táctica (Modo Pesadilla)
  final double _randomSeed = Random().nextDouble() * 10.0;
  double _chargeTimer = 0;
  bool _isCharging = false;
  Vector2? _chargeDirection;

  static final Paint _flashPaint = Paint()
    ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
  static final Paint _barBg = Paint()..color = Colors.black54;
  static final Paint _barHp = Paint()..color = const Color(0xFFFF5252);

  bool get isBoss =>
      type == EnemyType.boss ||
      type == EnemyType.bossIgnis ||
      type == EnemyType.bossGorgoroth ||
      type == EnemyType.bossVespertina ||
      type == EnemyType.bossValerius ||
      type == EnemyType.bossXulkrag;

  String get bossDisplayName {
    switch (type) {
      case EnemyType.bossIgnis:
        return 'IGNIS - EL COLOSO DE CENIZA';
      case EnemyType.bossGorgoroth:
        return 'GORGOROTH - TITÁN DE HUESO';
      case EnemyType.bossVespertina:
        return 'VESPERTINA - MATRIARCA DEL ENJAMBRE';
      case EnemyType.bossValerius:
        return 'ARCHIMAGO VALERIUS - EL HEREJE';
      case EnemyType.bossXulkrag:
        return 'XUL\'KRAG - DEVORADOR DE SOMBRAS';
      case EnemyType.boss:
      default:
        return 'LORD MALAKOR - SEÑOR DEL ABISMO';
    }
  }

  Color get bossAuraColor {
    switch (type) {
      case EnemyType.bossIgnis:
        return const Color(0xFFFF3D00); // Fuego incandescente
      case EnemyType.bossGorgoroth:
        return const Color(0xFF76FF03); // Verde necrótico
      case EnemyType.bossVespertina:
        return const Color(0xFFE040FB); // Violeta quimera
      case EnemyType.bossValerius:
        return const Color(0xFF2979FF); // Azul arcano
      case EnemyType.bossXulkrag:
        return const Color(0xFFD50000); // Carmesí abisal
      case EnemyType.boss:
      default:
        return const Color(0xFF00E5FF); // Cian Malakor
    }
  }

  EnemyComponent._({
    required Vector2 position,
    required this.type,
    required this.maxHp,
    required this.speed,
    required this.contactDamage,
    required this.expValue,
    required this.goldChance,
    required Vector2 size,
    this.sprite,
    this.isNightmare = true,
  })  : hp = maxHp,
        super(position: position, size: size, anchor: Anchor.center);

  // --- FACTORIES DE ENEMIGOS BÁSICOS ---

  factory EnemyComponent.bat(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 45.0 : 20.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.bat,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 105 : 90,
      contactDamage: (isNightmare ? 8.0 : 6.0) * difficultyMultiplier,
      expValue: isNightmare ? 15 : 12,
      goldChance: 25,
      size: Vector2(34, 30),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  factory EnemyComponent.skeleton(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 65.0 : 45.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.skeleton,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 65 : 60,
      contactDamage: (isNightmare ? 14.0 : 12.0) * difficultyMultiplier,
      expValue: isNightmare ? 30 : 25,
      goldChance: 50,
      size: Vector2(36, 44),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  factory EnemyComponent.brute(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 160.0 : 120.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.brute,
      maxHp: baseHp * difficultyMultiplier,
      speed: 42,
      contactDamage: (isNightmare ? 25.0 : 22.0) * difficultyMultiplier,
      expValue: isNightmare ? 80 : 70,
      goldChance: 90,
      size: Vector2(48, 54),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  factory EnemyComponent.cultist(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 70.0 : 40.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.cultist,
      maxHp: baseHp * difficultyMultiplier,
      speed: 55,
      contactDamage: (isNightmare ? 12.0 : 10.0) * difficultyMultiplier,
      expValue: isNightmare ? 40 : 35,
      goldChance: 40,
      size: Vector2(34, 46),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  factory EnemyComponent.bomber(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 55.0 : 24.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.bomber,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 130 : 115,
      contactDamage: (isNightmare ? 10.0 : 8.0) * difficultyMultiplier,
      expValue: isNightmare ? 25 : 20,
      goldChance: 35,
      size: Vector2(32, 34),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  // --- FACTORIES DE LOS 6 JEFES LEGENDARIOS ---

  // 1. Lord Malakor (Jefe Supremo Original)
  factory EnemyComponent.boss(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 780.0 : 480.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.boss,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 48 : 42,
      contactDamage: (isNightmare ? 30.0 : 25.0) * difficultyMultiplier,
      expValue: isNightmare ? 350 : 250,
      goldChance: 100,
      size: Vector2(68, 78),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  // 2. Ignis, el Coloso de Ceniza (Tier 1: Sencillo, pero con horda masiva de esbirros)
  factory EnemyComponent.bossIgnis(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 650.0 : 400.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.bossIgnis,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 46 : 40,
      contactDamage: (isNightmare ? 26.0 : 20.0) * difficultyMultiplier,
      expValue: isNightmare ? 300 : 200,
      goldChance: 100,
      size: Vector2(74, 82),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  // 3. Gorgoroth, Titán de Hueso (Tier 2: Ondas terrestres en 360°)
  factory EnemyComponent.bossGorgoroth(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 720.0 : 450.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.bossGorgoroth,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 44 : 38,
      contactDamage: (isNightmare ? 28.0 : 22.0) * difficultyMultiplier,
      expValue: isNightmare ? 320 : 220,
      goldChance: 100,
      size: Vector2(72, 80),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  // 4. Vespertina, Matriarca del Enjambre (Tier 3: Espirales venenosas veloces)
  factory EnemyComponent.bossVespertina(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 700.0 : 440.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.bossVespertina,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 56 : 48,
      contactDamage: (isNightmare ? 25.0 : 20.0) * difficultyMultiplier,
      expValue: isNightmare ? 340 : 240,
      goldChance: 100,
      size: Vector2(66, 72),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  // 5. Archimago Valerius (Tier 4: Teletransporte & Orbes arcanos teledirigidos)
  factory EnemyComponent.bossValerius(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 740.0 : 460.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.bossValerius,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 50 : 44,
      contactDamage: (isNightmare ? 28.0 : 22.0) * difficultyMultiplier,
      expValue: isNightmare ? 360 : 260,
      goldChance: 100,
      size: Vector2(62, 76),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  // 6. Xul'Krag, Devorador de Sombras (Tier 5: Vórtice gravitacional abisal)
  factory EnemyComponent.bossXulkrag(Vector2 position, double difficultyMultiplier, Sprite? sprite, {bool isNightmare = true}) {
    final baseHp = isNightmare ? 850.0 : 520.0;
    return EnemyComponent._(
      position: position,
      type: EnemyType.bossXulkrag,
      maxHp: baseHp * difficultyMultiplier,
      speed: isNightmare ? 42 : 36,
      contactDamage: (isNightmare ? 35.0 : 28.0) * difficultyMultiplier,
      expValue: isNightmare ? 400 : 300,
      goldChance: 100,
      size: Vector2(78, 88),
      sprite: sprite,
      isNightmare: isNightmare,
    );
  }

  @override
  void onMount() {
    super.onMount();
    game.activeEnemies.add(this);
    if (isBoss) {
      AudioManager.playBossRoar();
      game.updateBossHud();
      LogManager.log('EnemyComponent: Jefe $bossDisplayName montado en arena.');
    }
  }

  @override
  void onRemove() {
    game.activeEnemies.remove(this);
    if (isBoss) {
      game.updateBossHud();
    }
    super.onRemove();
  }

  @override
  void onLoad() {
    super.onLoad();
    final radius = isBoss ? 32.0 : (size.x * 0.4);
    _hitbox = CircleHitbox(radius: radius, anchor: Anchor.center, position: size / 2)..collisionType = CollisionType.passive;
    add(_hitbox);
  }

  @override
  void update(double dt) {
    if (_isDead) return;
    super.update(dt);

    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
    if (_attackCooldown > 0) {
      _attackCooldown -= dt;
    }

    final player = game.player;
    if (!player.isAlive) return;

    final diffX = player.position.x - position.x;
    final diffY = player.position.y - position.y;
    final distSq = diffX * diffX + diffY * diffY;

    // Culling: reposicionar si el enemigo común se aleja mucho
    if (!isBoss && distSq > 1440000) {
      position.setFrom(game.getRandomSpawnPosition());
      return;
    }

    // Daño de contacto al héroe
    final contactRadiusSq = isBoss ? 46 * 46 : 28 * 28;
    if (_attackCooldown <= 0 && distSq <= contactRadiusSq) {
      player.takeDamage(contactDamage);
      _attackCooldown = 0.6;
    }

    // --- HABILIDADES ESPECIALES DE LOS ENEMIGOS Y JEFES ---
    _specialTimer += dt;
    _handleSpecialAttacks(dt, player, diffX, diffY, distSq);

    // --- MOVIMIENTO E INTELIGENCIA ARTIFICIAL (NOVATO vs PESADILLA) ---
    _handleMovementAI(dt, player, diffX, diffY, distSq);
  }

  void _handleSpecialAttacks(double dt, PlayerComponent player, double diffX, double diffY, double distSq) {
    // 1. Mago Cultista (Disparo individual)
    if (type == EnemyType.cultist) {
      if (_specialTimer >= 2.4) {
        _specialTimer = 0;
        if (distSq <= 460 * 460 && distSq > 45 * 45) {
          AudioManager.playEnemyShoot();
          final dir = Vector2(diffX, diffY).normalized();
          game.world.add(EnemyBulletComponent(
            position: position.clone(),
            direction: dir,
            speed: 210,
            damage: 12,
          ));
        }
      }
      return;
    }

    // 2. Lord Malakor (Ráfaga triple en abanico + enrage < 30% HP)
    if (type == EnemyType.boss) {
      final interval = (hp < maxHp * 0.3) ? 1.5 : 2.2;
      if (_specialTimer >= interval) {
        _specialTimer = 0;
        if (distSq <= 560 * 560) {
          AudioManager.playEnemyShoot();
          final baseDir = Vector2(diffX, diffY).normalized();
          const spread = 0.42;
          for (final angleOffset in [-spread, 0.0, spread]) {
            final cosA = cos(angleOffset);
            final sinA = sin(angleOffset);
            final spreadDir = Vector2(
              baseDir.x * cosA - baseDir.y * sinA,
              baseDir.x * sinA + baseDir.y * cosA,
            );
            game.world.add(EnemyBulletComponent(
              position: position.clone(),
              direction: spreadDir,
              speed: 230,
              damage: 18,
            ));
          }
        }
      }
      return;
    }

    // 3. Ignis (Embestida Ígnea con aviso de rugido)
    if (type == EnemyType.bossIgnis) {
      if (_specialTimer >= 3.2) {
        _specialTimer = 0;
        if (distSq <= 500 * 500) {
          AudioManager.playBossRoar();
          _isCharging = true;
          _chargeTimer = 0.85;
          _chargeDirection = Vector2(diffX, diffY).normalized();
        }
      }
      return;
    }

    // 4. Gorgoroth (Pisotón sísmico con anillo 360° de 12 huesos)
    if (type == EnemyType.bossGorgoroth) {
      if (_specialTimer >= 2.8) {
        _specialTimer = 0;
        if (distSq <= 520 * 520) {
          AudioManager.playExplosion();
          const count = 12;
          for (int i = 0; i < count; i++) {
            final angle = (2 * pi / count) * i;
            final dir = Vector2(cos(angle), sin(angle));
            game.world.add(EnemyBulletComponent(
              position: position.clone(),
              direction: dir,
              speed: 190,
              damage: 14,
            ));
          }
        }
      }
      return;
    }

    // 5. Vespertina (Ráfaga continua en espiral tóxica)
    if (type == EnemyType.bossVespertina) {
      if (_specialTimer >= 1.6) {
        _specialTimer = 0;
        if (distSq <= 540 * 540) {
          AudioManager.playEnemyShoot();
          final baseAngle = game.elapsedTime * 3.0;
          for (int i = 0; i < 5; i++) {
            final angle = baseAngle + (i * 0.4);
            final dir = Vector2(cos(angle), sin(angle));
            game.world.add(EnemyBulletComponent(
              position: position.clone(),
              direction: dir,
              speed: 220,
              damage: 15,
            ));
          }
        }
      }
      return;
    }

    // 6. Archimago Valerius (Translocación / Teletransporte + 4 orbes lentos)
    if (type == EnemyType.bossValerius) {
      if (_specialTimer >= 4.2) {
        _specialTimer = 0;
        // Teletransporte táctico a rango medio
        final randAngle = Random().nextDouble() * 2 * pi;
        position.setFrom(player.position + Vector2(cos(randAngle), sin(randAngle)) * 220.0);
        AudioManager.playUltimate();
        // Disparo de 4 orbes arcanos
        for (int i = 0; i < 4; i++) {
          final angle = (pi / 2) * i + randAngle;
          game.world.add(EnemyBulletComponent(
            position: position.clone(),
            direction: Vector2(cos(angle), sin(angle)),
            speed: 175,
            damage: 20,
          ));
        }
      }
      return;
    }

    // 7. Xul'Krag (Vórtice abisal con arrastre gravitatorio)
    if (type == EnemyType.bossXulkrag) {
      if (_specialTimer >= 3.6) {
        _specialTimer = 0;
        AudioManager.playEnemyShoot();
        // Disparo frontal doble
        final dir = Vector2(diffX, diffY).normalized();
        game.world.add(EnemyBulletComponent(position: position.clone() + Vector2(10, 0), direction: dir, speed: 240, damage: 22));
        game.world.add(EnemyBulletComponent(position: position.clone() - Vector2(10, 0), direction: dir, speed: 240, damage: 22));
      }
      // Efecto gravitacional pasivo: tira ligeramente del héroe si está cerca
      if (distSq <= 380 * 380 && distSq > 30 * 30) {
        final pullDir = Vector2(-diffX, -diffY).normalized();
        player.position += pullDir * (45 * dt);
      }
      return;
    }
  }

  void _handleMovementAI(double dt, PlayerComponent player, double diffX, double diffY, double distSq) {
    if (distSq <= 1) return;
    final dist = sqrt(distSq);
    final normX = diffX / dist;
    final normY = diffY / dist;
    _facingDirection = normX >= 0 ? 1.0 : -1.0;

    // A. Si está ejecutando una carga de embestida (Ignis o Bruto en Pesadilla)
    if (_isCharging && _chargeDirection != null) {
      _chargeTimer -= dt;
      final chargeSpeed = speed * 2.3;
      position.x += _chargeDirection!.x * (chargeSpeed * dt);
      position.y += _chargeDirection!.y * (chargeSpeed * dt);
      if (_chargeTimer <= 0) {
        _isCharging = false;
        _chargeDirection = null;
      }
      return;
    }

    // B. MODO NOVATO: Movimiento directo y predecible para accesibilidad
    if (!isNightmare) {
      if (type == EnemyType.cultist && dist < 140) {
        position.x -= normX * (speed * 0.7 * dt);
        position.y -= normY * (speed * 0.7 * dt);
      } else {
        position.x += normX * (speed * dt);
        position.y += normY * (speed * dt);
      }
      return;
    }

    // C. MODO PESADILLA: IA TÁCTICA AVANZADA

    // 1. Murciélagos: Trayectoria sinusoidal envolvente (cortan el paso al héroe)
    if (type == EnemyType.bat) {
      final perpX = -normY;
      final perpY = normX;
      final wave = sin(game.elapsedTime * 4.5 + _randomSeed) * 0.75;
      final moveX = (normX + perpX * wave);
      final moveY = (normY + perpY * wave);
      final len = sqrt(moveX * moveX + moveY * moveY);
      position.x += (moveX / len) * (speed * dt);
      position.y += (moveY / len) * (speed * dt);
      return;
    }

    // 2. Esqueletos: Despliegue en abanico / pinza para rodear en semicírculo
    if (type == EnemyType.skeleton) {
      final perpX = -normY;
      final perpY = normX;
      final lateralBias = sin(_randomSeed) * 0.45;
      final moveX = normX + perpX * lateralBias;
      final moveY = normY + perpY * lateralBias;
      final len = sqrt(moveX * moveX + moveY * moveY);
      position.x += (moveX / len) * (speed * dt);
      position.y += (moveY / len) * (speed * dt);
      return;
    }

    // 3. Brutos: Carga en frenesí cuando entran en rango medio
    if (type == EnemyType.brute) {
      _chargeTimer -= dt;
      if (_chargeTimer <= 0 && dist >= 130 && dist <= 240) {
        _isCharging = true;
        _chargeTimer = 4.0; // Cooldown
        _chargeDirection = Vector2(normX, normY);
        return;
      }
      position.x += normX * (speed * dt);
      position.y += normY * (speed * dt);
      return;
    }

    // 4. Cultistas: Kiting inteligente (retroceso y órbita lateral)
    if (type == EnemyType.cultist) {
      if (dist < 180) {
        // Demasiado cerca: retroceso táctico
        position.x -= normX * (speed * 0.85 * dt);
        position.y -= normY * (speed * 0.85 * dt);
      } else if (dist <= 270) {
        // Distancia óptima: rodear lateralmente mientras disparan
        final perpX = -normY;
        final perpY = normX;
        position.x += perpX * (speed * 0.65 * dt);
        position.y += perpY * (speed * 0.65 * dt);
      } else {
        // Lejos: acercarse al rango de tiro
        position.x += normX * (speed * dt);
        position.y += normY * (speed * dt);
      }
      return;
    }

    // 5. Duendes Bomba: Aceleración frenética si están a menos de 160px
    if (type == EnemyType.bomber) {
      final sprint = dist < 160 ? 1.35 : 1.0;
      position.x += normX * (speed * sprint * dt);
      position.y += normY * (speed * sprint * dt);
      return;
    }

    // 6. Jefes: Avance implacable con leve aceleración si están heridos
    final enrageBoost = (isBoss && hp < maxHp * 0.3) ? 1.25 : 1.0;
    position.x += normX * (speed * enrageBoost * dt);
    position.y += normY * (speed * enrageBoost * dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Aura distintiva luminosa para los Jefes
    if (isBoss) {
      final auraPaint = Paint()
        ..color = bossAuraColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.55, auraPaint);
    }

    if (sprite != null) {
      canvas.save();
      if (_facingDirection < 0) {
        canvas.translate(size.x, 0);
        canvas.scale(-1, 1);
      }

      if (_flashTimer > 0) {
        sprite!.render(canvas, size: size, overridePaint: _flashPaint);
      } else {
        sprite!.render(canvas, size: size);
      }
      canvas.restore();
    }

    // Barra de vida si ha recibido daño (en jefes se ve en el HUD superior)
    if (!isBoss && hp < maxHp) {
      final barWidth = size.x;
      const barHeight = 4.0;
      final barRect = Rect.fromLTWH(0, -8, barWidth, barHeight);
      canvas.drawRect(barRect, _barBg);
      final hpWidth = (hp / maxHp).clamp(0.0, 1.0) * barWidth;
      canvas.drawRect(Rect.fromLTWH(0, -8, hpWidth, barHeight), _barHp);
    }
  }

  void takeDamage(double damage) {
    if (_isDead) return;
    hp -= damage;
    _flashTimer = 0.08;

    if (isBoss) {
      game.updateBossHud();
    }

    if (hp <= 0) {
      die();
    }
  }

  void die() {
    if (_isDead) return;
    _isDead = true;

    // Desactivar hitbox de colisión y remover inmediatamente de la lista activa
    _hitbox.collisionType = CollisionType.inactive;
    game.activeEnemies.remove(this);

    if (isBoss) {
      LogManager.log('EnemyComponent: Murió Jefe $bossDisplayName');
    }
    game.onEnemyKilled(this);

    // Si es un Duende Bomba, explota con daño de área
    if (type == EnemyType.bomber) {
      game.world.add(ExplosionComponent(position: position.clone(), damage: 24));
    }

    // Si es cualquier Jefe, recompensa legendaria masiva
    if (isBoss) {
      for (int i = 0; i < 4; i++) {
        game.spawnGem(position + Vector2((i - 1.5) * 20.0, 0), GemType.exp, 100);
        game.spawnGem(position + Vector2((i - 1.5) * 20.0, 20.0), GemType.gold, 30);
      }
    } else {
      // Gemas comunes
      game.spawnGem(position.clone(), GemType.exp, expValue);
      if (Random().nextInt(100) < goldChance) {
        game.spawnGem(position.clone() + Vector2(8, 0), GemType.gold, 5);
      }
    }

    removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_isDead) return;
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && _attackCooldown <= 0) {
      other.takeDamage(contactDamage);
      _attackCooldown = 0.6;
    }
  }
}
