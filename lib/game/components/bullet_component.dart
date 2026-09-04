import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
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
    position += direction * (speed * dt);
    _distanceTraveled += speed * dt;

    if (_distanceTraveled >= maxRange) {
      removeFromParent();
    }
  }

  static final Paint _glowPaint = Paint()..color = const Color(0x5500E5FF);
  static final Paint _corePaint = Paint()..color = const Color(0xFF00E5FF);
  static final Paint _highlightPaint = Paint()..color = Colors.white;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, size.x / 2 + 2, _glowPaint);
    canvas.drawCircle(center, size.x / 2 - 1, _corePaint);
    canvas.drawCircle(Offset(size.x / 2 - 1, size.y / 2 - 1), size.x / 4, _highlightPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent) {
      AudioManager.playHit();
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}
