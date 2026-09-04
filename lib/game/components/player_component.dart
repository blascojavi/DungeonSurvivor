import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'bullet_component.dart';
import 'enemy_component.dart';
import 'gem_component.dart';
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
  Vector2 moveDirection = Vector2.zero();

  PlayerComponent({
    required Vector2 position,
    this.maxHp = 100,
    this.speed = 180,
    this.magnetRadius = 120,
    this.attackInterval = 0.5,
    this.bulletDamage = 25,
  })  : hp = maxHp,
        super(position: position, size: Vector2(36, 36), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) return;

    // 1. Movimiento por Joystick o teclado
    if (!moveDirection.isZero()) {
      position += moveDirection.normalized() * (speed * dt);
      
      // Limitar dentro del mapa (1600 x 1600)
      position.x = position.x.clamp(20.0, 1580.0);
      position.y = position.y.clamp(20.0, 1580.0);
    }

    // 2. Disparo automático al enemigo más cercano
    _shootTimer += dt;
    if (_shootTimer >= attackInterval) {
      _shootTimer = 0;
      _autoFireNearestEnemy();
    }

    // 3. Imán de gemas
    _attractNearbyGems();
  }

  void _autoFireNearestEnemy() {
    final enemies = game.world.children.whereType<EnemyComponent>().toList();
    if (enemies.isEmpty) return;

    EnemyComponent? nearest;
    double minDistance = double.infinity;

    for (final enemy in enemies) {
      final dist = (enemy.position - position).length;
      if (dist < minDistance && dist < 450) {
        // Rango de visión de disparo: 450 px
        minDistance = dist;
        nearest = enemy;
      }
    }

    if (nearest != null) {
      final dir = (nearest.position - position).normalized();
      game.world.add(BulletComponent(
        position: position.clone(),
        direction: dir,
        damage: bulletDamage,
      ));
    }
  }

  void _attractNearbyGems() {
    final gems = game.world.children.whereType<GemComponent>();
    for (final gem in gems) {
      if (!gem.isAttracted) {
        final dist = (gem.position - position).length;
        if (dist <= magnetRadius) {
          gem.attract();
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Aura o halo brillante
    final auraPaint = Paint()
      ..color = const Color(0x333F51B5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 6, auraPaint);

    // Armadura / Túnica del Héroe (Azul cobalto místico)
    final heroPaint = Paint()
      ..color = const Color(0xFF2979FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, heroPaint);

    // Yelmo dorado / Visera
    final helmetPaint = Paint()..color = const Color(0xFFFFD700);
    final helmetRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * 0.4),
      width: size.x * 0.6,
      height: size.y * 0.3,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(helmetRect, const Radius.circular(4)), helmetPaint);

    // Ojos del yelmo
    final eyePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(size.x * 0.4, size.y * 0.4), 2, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.6, size.y * 0.4), 2, eyePaint);
  }

  void takeDamage(double amount) {
    if (!isAlive) return;

    hp -= amount;
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
    if (currentExp >= expToNextLevel) {
      currentExp -= expToNextLevel;
      level++;
      expToNextLevel = (expToNextLevel * 1.3).round();
      game.onPlayerLevelUp(level);
    }
    game.onPlayerExpChanged(currentExp, expToNextLevel, level);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is GemComponent) {
      if (other.type == GemType.exp) {
        addExp(other.value);
      } else if (other.type == GemType.gold) {
        game.addGold(other.value);
      }
      other.removeFromParent();
    }
  }
}
