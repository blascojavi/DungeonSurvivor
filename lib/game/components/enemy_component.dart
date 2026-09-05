import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import 'enemy_bullet_component.dart';
import 'explosion_component.dart';
import 'gem_component.dart';
import 'player_component.dart';
import '../dungeon_game.dart';

enum EnemyType { bat, skeleton, brute, cultist, bomber, boss }

class EnemyComponent extends PositionComponent with CollisionCallbacks, HasGameReference<DungeonGame> {
  final EnemyType type;
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

  static final Paint _flashPaint = Paint()
    ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
  static final Paint _barBg = Paint()..color = Colors.black54;
  static final Paint _barHp = Paint()..color = const Color(0xFFFF5252);

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
  })  : hp = maxHp,
        super(position: position, size: size, anchor: Anchor.center);

  factory EnemyComponent.bat(Vector2 position, double difficultyMultiplier, Sprite? sprite) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.bat,
      maxHp: 45 * difficultyMultiplier,
      speed: 100,
      contactDamage: 8 * difficultyMultiplier,
      expValue: 15,
      goldChance: 25,
      size: Vector2(34, 30),
      sprite: sprite,
    );
  }

  factory EnemyComponent.skeleton(Vector2 position, double difficultyMultiplier, Sprite? sprite) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.skeleton,
      maxHp: 65 * difficultyMultiplier,
      speed: 65,
      contactDamage: 14 * difficultyMultiplier,
      expValue: 30,
      goldChance: 50,
      size: Vector2(36, 44),
      sprite: sprite,
    );
  }

  factory EnemyComponent.brute(Vector2 position, double difficultyMultiplier, Sprite? sprite) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.brute,
      maxHp: 160 * difficultyMultiplier,
      speed: 40,
      contactDamage: 25 * difficultyMultiplier,
      expValue: 80,
      goldChance: 90,
      size: Vector2(48, 54),
      sprite: sprite,
    );
  }

  factory EnemyComponent.cultist(Vector2 position, double difficultyMultiplier, Sprite? sprite) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.cultist,
      maxHp: 70 * difficultyMultiplier,
      speed: 55,
      contactDamage: 12 * difficultyMultiplier,
      expValue: 40,
      goldChance: 40,
      size: Vector2(34, 46),
      sprite: sprite,
    );
  }

  factory EnemyComponent.bomber(Vector2 position, double difficultyMultiplier, Sprite? sprite) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.bomber,
      maxHp: 55 * difficultyMultiplier,
      speed: 130, // Rápido y errático
      contactDamage: 10 * difficultyMultiplier,
      expValue: 25,
      goldChance: 35,
      size: Vector2(32, 34),
      sprite: sprite,
    );
  }

  factory EnemyComponent.boss(Vector2 position, double difficultyMultiplier, Sprite? sprite) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.boss,
      maxHp: 780 * difficultyMultiplier,
      speed: 45,
      contactDamage: 30 * difficultyMultiplier,
      expValue: 350,
      goldChance: 100,
      size: Vector2(65, 75),
      sprite: sprite,
    );
  }

  @override
  void onMount() {
    super.onMount();
    game.activeEnemies.add(this);
    if (type == EnemyType.boss) {
      AudioManager.playBossRoar();
      game.updateBossHud();
    }
  }

  @override
  void onRemove() {
    game.activeEnemies.remove(this);
    if (type == EnemyType.boss) {
      game.updateBossHud();
    }
    super.onRemove();
  }

  @override
  void onLoad() {
    super.onLoad();
    // Hitbox pasiva: colisiona con proyectiles y jugador, pero NUNCA calcula pares enemigo-enemigo
    final radius = type == EnemyType.boss ? 30.0 : (size.x * 0.4);
    add(CircleHitbox(radius: radius, anchor: Anchor.center, position: size / 2)..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
    if (_attackCooldown > 0) {
      _attackCooldown -= dt;
    }

    final player = game.player;
    if (player.isAlive) {
      final diffX = player.position.x - position.x;
      final diffY = player.position.y - position.y;
      final distSq = diffX * diffX + diffY * diffY;

      // Culling: si un enemigo común se aleja demasiado (> 1200 px), reposicionarlo cerca del jugador (salvo el jefe)
      if (type != EnemyType.boss && distSq > 1440000) {
        position.setFrom(game.getRandomSpawnPosition());
        return;
      }

      // Daño continuo al jugador por proximidad física (sin sobrecarga de colisión continua)
      final contactRadiusSq = type == EnemyType.boss ? 42 * 42 : 28 * 28;
      if (_attackCooldown <= 0 && distSq <= contactRadiusSq) {
        player.takeDamage(contactDamage);
        _attackCooldown = 0.6;
      }

      // Ataque especial a distancia del Cultista (disparo individual)
      if (type == EnemyType.cultist) {
        _specialTimer += dt;
        if (_specialTimer >= 2.5) {
          _specialTimer = 0;
          if (distSq <= 460 * 460 && distSq > 50 * 50) {
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
      }

      // Ataque especial del Jefe (ráfaga triple en abanico)
      if (type == EnemyType.boss) {
        _specialTimer += dt;
        if (_specialTimer >= 2.2) {
          _specialTimer = 0;
          if (distSq <= 550 * 550) {
            AudioManager.playEnemyShoot();
            final baseDir = Vector2(diffX, diffY).normalized();
            const spread = 0.42; // ~24 grados
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
      }

      if (distSq > 1) {
        final dist = sqrt(distSq);
        final normX = diffX / dist;
        final normY = diffY / dist;
        _facingDirection = normX >= 0 ? 1.0 : -1.0;

        // El cultista guarda un poco de distancia si está demasiado cerca
        if (type == EnemyType.cultist && dist < 140) {
          position.x -= normX * (speed * 0.7 * dt);
          position.y -= normY * (speed * 0.7 * dt);
        } else {
          position.x += normX * (speed * dt);
          position.y += normY * (speed * dt);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

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

    // Barra de vida si ha recibido daño (en el jefe se muestra en el HUD superior)
    if (type != EnemyType.boss && hp < maxHp) {
      final barWidth = size.x;
      const barHeight = 4.0;
      final barRect = Rect.fromLTWH(0, -8, barWidth, barHeight);
      final hpRatio = (hp / maxHp).clamp(0.0, 1.0);

      canvas.drawRect(barRect, _barBg);
      canvas.drawRect(Rect.fromLTWH(0, -8, barWidth * hpRatio, barHeight), _barHp);
    }
  }

  void takeDamage(double amount) {
    hp -= amount;
    _flashTimer = 0.08;

    if (type == EnemyType.boss) {
      game.updateBossHud();
    }

    if (hp <= 0) {
      die();
    }
  }

  void die() {
    game.onEnemyKilled(this);

    // Si es un Duende Bomba, explota al morir con daño de área
    if (type == EnemyType.bomber) {
      game.world.add(ExplosionComponent(position: position.clone(), damage: 24));
    }

    // Si es el Jefe, recompensa legendaria masiva
    if (type == EnemyType.boss) {
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
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && _attackCooldown <= 0) {
      other.takeDamage(contactDamage);
      _attackCooldown = 0.6;
    }
  }
}
