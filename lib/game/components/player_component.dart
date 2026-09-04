import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import 'bullet_component.dart';
import 'enemy_component.dart';
import '../dungeon_game.dart';

class PlayerComponent extends PositionComponent with CollisionCallbacks, HasGameReference<DungeonGame> {
  // Estadísticas del jugador
  double maxHp;
  double hp;
  double speed;
  double magnetRadius;
  double attackInterval;
  double bulletDamage;
  int level = 1;
  int currentExp = 0;
  int expToNextLevel = 50;

  // Estado interno
  bool isAlive = true;
  double _shootTimer = 0;
  double _magnetTimer = 0;
  double _invulnerableTimer = 0;
  Vector2 moveDirection = Vector2.zero();
  Sprite? _heroSprite;

  static final Paint _auraPaint = Paint()..color = const Color(0x3300E5FF);
  static final Paint _fallbackPaint = Paint()..color = const Color(0xFF2979FF);

  PlayerComponent({
    required Vector2 position,
    this.maxHp = 100,
    this.speed = 180,
    this.magnetRadius = 120,
    this.attackInterval = 0.5,
    this.bulletDamage = 25,
  })  : hp = maxHp,
        super(position: position, size: Vector2(36, 52), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Hitbox en el torso/base para colisiones justas
    add(CircleHitbox(radius: 16, position: Vector2(size.x / 2 - 16, size.y - 34))..collisionType = CollisionType.active);
    try {
      _heroSprite = await game.loadSprite('hero.png');
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) return;

    if (_invulnerableTimer > 0) {
      _invulnerableTimer -= dt;
    }

    // 1. Movimiento por Joystick o teclado
    if (!moveDirection.isZero()) {
      position += moveDirection.normalized() * (speed * dt);
      position.x = position.x.clamp(20.0, 1580.0);
      position.y = position.y.clamp(20.0, 1580.0);
    }

    // 2. Disparo automático al enemigo más cercano
    _shootTimer += dt;
    if (_shootTimer >= attackInterval) {
      _shootTimer = 0;
      _autoFireNearestEnemy();
    }

    // 3. Imán de gemas throttled (cada 120ms para rendimiento a 60/120 FPS)
    _magnetTimer += dt;
    if (_magnetTimer >= 0.12) {
      _magnetTimer = 0;
      _attractNearbyGems();
    }
  }

  void _autoFireNearestEnemy() {
    final enemies = game.activeEnemies;
    if (enemies.isEmpty) return;

    EnemyComponent? nearest;
    double minDistanceSq = double.infinity;
    const maxRange = 450.0;
    const maxRangeSq = maxRange * maxRange;

    for (int i = 0; i < enemies.length; i++) {
      final enemy = enemies[i];
      if (!enemy.isMounted) continue;
      // length2 evita el cálculo costoso de raíz cuadrada (sqrt)
      final distSq = (enemy.position - position).length2;
      if (distSq < minDistanceSq && distSq < maxRangeSq) {
        minDistanceSq = distSq;
        nearest = enemy;
      }
    }

    if (nearest != null) {
      AudioManager.playShoot();
      final dir = (nearest.position - position).normalized();
      game.world.add(BulletComponent(
        position: position.clone(),
        direction: dir,
        damage: bulletDamage,
      ));
    }
  }

  void _attractNearbyGems() {
    final magnetRadiusSq = magnetRadius * magnetRadius;
    final gems = game.activeGems;
    for (int i = 0; i < gems.length; i++) {
      final gem = gems[i];
      if (!gem.isAttracted) {
        final distSq = (gem.position - position).length2;
        if (distSq <= magnetRadiusSq) {
          gem.attract();
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isAlive) return;

    // Parpadeo durante el tiempo de invulnerabilidad tras recibir daño
    if (_invulnerableTimer > 0 && (_invulnerableTimer * 24).toInt() % 2 == 0) {
      return;
    }

    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);

    // Halo ligero sin desenfoque costoso
    canvas.drawCircle(center, size.x / 2 + 3, _auraPaint);

    if (_heroSprite != null) {
      if (moveDirection.x < 0) {
        // Volteo horizontal si se mueve a la izquierda
        canvas.save();
        canvas.translate(size.x, 0);
        canvas.scale(-1, 1);
        _heroSprite!.render(canvas, size: size);
        canvas.restore();
      } else {
        _heroSprite!.render(canvas, size: size);
      }
    } else {
      canvas.drawCircle(center, size.x / 2, _fallbackPaint);
    }
  }

  void takeDamage(double amount) {
    if (!isAlive || _invulnerableTimer > 0) return;

    _invulnerableTimer = 0.45; // 450ms de i-frames para no saturar colisiones ni audio
    hp -= amount;
    AudioManager.playHurt();
    game.onPlayerHealthChanged(hp, maxHp);

    if (hp <= 0) {
      hp = 0;
      isAlive = false;
      game.onGameOver();
    }
  }

  void heal(double amount) {
    hp = (hp + amount).clamp(0.0, maxHp);
    game.onPlayerHealthChanged(hp, maxHp);
  }

  void addExp(int amount) {
    currentExp += amount;
    while (currentExp >= expToNextLevel) {
      currentExp -= expToNextLevel;
      level++;
      expToNextLevel = (expToNextLevel * 1.3).round();
      game.queuePlayerLevelUp(level);
    }
    game.onPlayerExpChanged(currentExp, expToNextLevel, level);
  }

  // --- Habilidad Definitiva (Ultimate) ---
  int ultimateKills = 0;
  static const int requiredUltimateKills = 20;

  void onEnemyKilled() {
    if (ultimateKills < requiredUltimateKills) {
      ultimateKills++;
      game.onUltimateChargeChanged(ultimateKills / requiredUltimateKills);
    }
  }

  void triggerUltimate() {
    if (ultimateKills < requiredUltimateKills || !isAlive) return;
    ultimateKills = 0;
    game.onUltimateChargeChanged(0.0);
    AudioManager.playUltimate();

    // 1. Descarga masiva radial de 18 proyectiles en 360 grados
    const int projectileCount = 18;
    for (int i = 0; i < projectileCount; i++) {
      final angle = i * (2 * 3.14159265 / projectileCount);
      final dir = Vector2(cos(angle), sin(angle));
      game.world.add(BulletComponent(
        position: position.clone(),
        direction: dir,
        damage: bulletDamage * 2.5,
        speed: 520,
        maxRange: 750,
      ));
    }

    // 2. Onda expansiva con daño y repulsión a todos los enemigos cercanos
    final enemies = game.activeEnemies;
    for (int i = 0; i < enemies.length; i++) {
      final e = enemies[i];
      if (!e.isMounted) continue;
      final diff = e.position - position;
      final distSq = diff.length2;
      if (distSq <= 280 * 280 && distSq > 1) {
        final pushDir = diff.normalized();
        e.position += pushDir * 90;
        e.takeDamage(bulletDamage * 1.5);
      }
    }
  }
}
