import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player_component.dart';

enum GemType { exp, gold }

class GemComponent extends PositionComponent with CollisionCallbacks {
  final GemType type;
  final int value;
  bool isAttracted = false;
  double attractSpeed = 150;

  GemComponent({
    required Vector2 position,
    required this.type,
    this.value = 10,
  }) : super(
          position: position,
          size: Vector2(14, 14),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isAttracted) {
      final player = parent?.children.whereType<PlayerComponent>().firstOrNull;
      if (player != null) {
        final toPlayer = player.position - position;
        final distance = toPlayer.length;
        if (distance > 5) {
          attractSpeed += 600 * dt; // Aceleración suave
          position += toPlayer.normalized() * (attractSpeed * dt);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final isExp = type == GemType.exp;
    final primaryColor = isExp ? const Color(0xFF00FF88) : const Color(0xFFFFD700);

    // Brillo exterior
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 2, glowPaint);

    // Diamante / Gema
    final path = Path();
    path.moveTo(size.x / 2, 1);
    path.lineTo(size.x - 1, size.y / 2);
    path.lineTo(size.x / 2, size.y - 1);
    path.lineTo(1, size.y / 2);
    path.close();

    final gemPaint = Paint()..color = primaryColor;
    canvas.drawPath(path, gemPaint);

    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(size.x / 2, size.y / 3), 2, highlightPaint);
  }

  void attract() {
    isAttracted = true;
  }
}
