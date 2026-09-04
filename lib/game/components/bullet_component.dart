import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_component.dart';

class BulletComponent extends PositionComponent with CollisionCallbacks {
  final Vector2 direction;
  final double speed;
  final double damage;
  final double maxRange;
  double _distanceTraveled = 0;

  BulletComponent({
    required Vector2 position,
    required this.direction,
    this.speed = 450,
    this.damage = 25,
    this.maxRange = 600,
  }) : super(
          position: position,
          size: Vector2(12, 12),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final delta = direction * (speed * dt);
    position += delta;
    _distanceTraveled += delta.length;

    if (_distanceTraveled >= maxRange) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Renderizado de orbe de energía arcana
    final glowPaint = Paint()
      ..color = const Color(0x6600E5FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 3, glowPaint);

    final corePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, corePaint);

    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x / 2 - 1, size.y / 2 - 1), size.x / 4, highlightPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}
