import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player_component.dart';
import 'gem_component.dart';
import '../dungeon_game.dart';

enum EnemyType { bat, skeleton, brute }

class EnemyComponent extends PositionComponent with CollisionCallbacks, HasGameReference<DungeonGame> {
  final EnemyType type;
  double hp;
  final double maxHp;
  final double speed;
  final double contactDamage;
  final int expValue;
  final int goldChance; // Probabilidad de soltar oro (0-100)

  double _flashTimer = 0;
  double _attackCooldown = 0;

  EnemyComponent._({
    required Vector2 position,
    required this.type,
    required this.maxHp,
    required this.speed,
    required this.contactDamage,
    required this.expValue,
    required this.goldChance,
    required Vector2 size,
  })  : hp = maxHp,
        super(position: position, size: size, anchor: Anchor.center);

  factory EnemyComponent.bat(Vector2 position, double difficultyMultiplier) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.bat,
      maxHp: 20 * difficultyMultiplier,
      speed: 95,
      contactDamage: 8 * difficultyMultiplier,
      expValue: 15,
      goldChance: 25,
      size: Vector2(24, 24),
    );
  }

  factory EnemyComponent.skeleton(Vector2 position, double difficultyMultiplier) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.skeleton,
      maxHp: 45 * difficultyMultiplier,
      speed: 65,
      contactDamage: 14 * difficultyMultiplier,
      expValue: 30,
      goldChance: 50,
      size: Vector2(30, 30),
    );
  }

  factory EnemyComponent.brute(Vector2 position, double difficultyMultiplier) {
    return EnemyComponent._(
      position: position,
      type: EnemyType.brute,
      maxHp: 120 * difficultyMultiplier,
      speed: 40,
      contactDamage: 25 * difficultyMultiplier,
      expValue: 80,
      goldChance: 90,
      size: Vector2(42, 42),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox()..collisionType = CollisionType.active);
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

    // Perseguir al jugador
    final player = game.player;
    if (player.isAlive) {
      final direction = (player.position - position).normalized();
      position += direction * (speed * dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final isFlashing = _flashTimer > 0;

    Color baseColor;
    switch (type) {
      case EnemyType.bat:
        baseColor = const Color(0xFF9C27B0); // Púrpura sombrío
        break;
      case EnemyType.skeleton:
        baseColor = const Color(0xFFCFD8DC); // Gris hueso
        break;
      case EnemyType.brute:
        baseColor = const Color(0xFFE53935); // Rojo demoníaco
        break;
    }

    final paint = Paint()
      ..color = isFlashing ? Colors.white : baseColor
      ..style = PaintingStyle.fill;

    // Dibujar cuerpo según el tipo
    if (type == EnemyType.bat) {
      // Forma de murciélago con alas
      final path = Path();
      path.moveTo(size.x / 2, size.y * 0.2);
      path.lineTo(size.x, size.y * 0.4);
      path.lineTo(size.x * 0.7, size.y * 0.8);
      path.lineTo(size.x / 2, size.y * 0.6);
      path.lineTo(size.x * 0.3, size.y * 0.8);
      path.lineTo(0, size.y * 0.4);
      path.close();
      canvas.drawPath(path, paint);

      // Ojos rojos brillantes
      final eyePaint = Paint()..color = const Color(0xFFFF1744);
      canvas.drawCircle(Offset(size.x * 0.4, size.y * 0.4), 2, eyePaint);
      canvas.drawCircle(Offset(size.x * 0.6, size.y * 0.4), 2, eyePaint);
    } else {
      // Silueta circular con borde estilizado
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

      // Ojos malévolos
      final eyePaint = Paint()..color = const Color(0xFFFFD600);
      canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.4), size.x * 0.08, eyePaint);
      canvas.drawCircle(Offset(size.x * 0.65, size.y * 0.4), size.x * 0.08, eyePaint);

      // Barra de vida si ha recibido daño
      if (hp < maxHp) {
        final barWidth = size.x;
        const barHeight = 4.0;
        final barRect = Rect.fromLTWH(0, -8, barWidth, barHeight);
        final hpRatio = (hp / maxHp).clamp(0.0, 1.0);

        final bgPaint = Paint()..color = Colors.black54;
        canvas.drawRect(barRect, bgPaint);

        final hpPaint = Paint()..color = const Color(0xFFFF5252);
        canvas.drawRect(Rect.fromLTWH(0, -8, barWidth * hpRatio, barHeight), hpPaint);
      }
    }
  }

  void takeDamage(double amount) {
    hp -= amount;
    _flashTimer = 0.08; // Flash blanco al recibir impacto

    if (hp <= 0) {
      die();
    }
  }

  void die() {
    game.onEnemyKilled(this);

    // Soltar gema de EXP
    parent?.add(GemComponent(
      position: position.clone(),
      type: GemType.exp,
      value: expValue,
    ));

    // Probabilidad de soltar moneda de oro
    if (Random().nextInt(100) < goldChance) {
      parent?.add(GemComponent(
        position: position.clone() + Vector2(8, 0),
        type: GemType.gold,
        value: 5,
      ));
    }

    removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerComponent && _attackCooldown <= 0) {
      other.takeDamage(contactDamage);
      _attackCooldown = 0.8; // Cooldown de ataque para no drenar toda la vida instantáneamente
    }
  }
}
