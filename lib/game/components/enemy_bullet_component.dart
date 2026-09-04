import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player_component.dart';

class EnemyBulletComponent extends PositionComponent with CollisionCallbacks {
  final Vector2 direction;
  final double speed;
  final double damage;
  final double maxRange;
  double _distanceTraveled = 0;

  static final Paint _glowPaint = Paint()..color = const Color(0x66FF1744);
  static final Paint _corePaint = Paint()..color = const Color(0xFFFF1744);
  static final Paint _centerPaint = Paint()..color = const Color(0xFFFF8A80);

  EnemyBulletComponent({
    required Vector2 position,
    required this.direction,
    this.speed = 220,
    this.damage = 12,
    this.maxRange = 550,
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
    position += direction * (speed * dt);
    _distanceTraveled += speed * dt;

    if (_distanceTraveled >= maxRange) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, size.x / 2 + 2, _glowPaint);
    canvas.drawCircle(center, size.x / 2 - 1, _corePaint);
    canvas.drawCircle(center, size.x / 4, _centerPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}
