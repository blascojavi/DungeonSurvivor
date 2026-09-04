import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'gem_component.dart';
import 'player_component.dart';
import '../dungeon_game.dart';

enum EnemyType { bat, skeleton, brute }

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
      maxHp: 20 * difficultyMultiplier,
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
      maxHp: 45 * difficultyMultiplier,
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
      maxHp: 120 * difficultyMultiplier,
      speed: 40,
      contactDamage: 25 * difficultyMultiplier,
      expValue: 80,
      goldChance: 90,
      size: Vector2(48, 54),
      sprite: sprite,
    );
  }

  @override
  void onMount() {
    super.onMount();
    game.activeEnemies.add(this);
  }

  @override
  void onRemove() {
    game.activeEnemies.remove(this);
    super.onRemove();
  }

  @override
  void onLoad() {
    super.onLoad();
    // Hitbox pasiva: colisiona con proyectiles y jugador, pero NUNCA calcula pares enemigo-enemigo
    add(CircleHitbox()..collisionType = CollisionType.passive);
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

      // Culling: si el enemigo se aleja demasiado (> 1200 px), reposicionarlo cerca del borde visible
      if (distSq > 1440000) {
        position.setFrom(game.getRandomSpawnPosition());
        return;
      }

      // Daño continuo al jugador por proximidad física (sin generar sets de colisión cada frame)
      if (_attackCooldown <= 0 && distSq <= 28 * 28) {
        player.takeDamage(contactDamage);
        _attackCooldown = 0.6;
      }

      if (distSq > 1) {
        final dist = sqrt(distSq);
        final normX = diffX / dist;
        final normY = diffY / dist;
        _facingDirection = normX >= 0 ? 1.0 : -1.0;
        position.x += normX * (speed * dt);
        position.y += normY * (speed * dt);
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

    // Barra de vida si ha recibido daño
    if (hp < maxHp) {
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

    if (hp <= 0) {
      die();
    }
  }

  void die() {
    game.onEnemyKilled(this);

    // Gemas de EXP y Oro limitadas con pool para que el juego nunca se cuelgue
    game.spawnGem(position.clone(), GemType.exp, expValue);

    if (Random().nextInt(100) < goldChance) {
      game.spawnGem(position.clone() + Vector2(8, 0), GemType.gold, 5);
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
