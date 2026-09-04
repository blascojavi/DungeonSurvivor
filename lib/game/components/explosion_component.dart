import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../dungeon_game.dart';

class ExplosionComponent extends PositionComponent with HasGameReference<DungeonGame> {
  final double maxRadius;
  final double damage;
  final double duration;
  double _timer = 0;
  bool _hasDamaged = false;

  static final Paint _outerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  static final Paint _corePaint = Paint()..style = PaintingStyle.fill;

  ExplosionComponent({
    required Vector2 position,
    this.maxRadius = 65,
    this.damage = 22,
    this.duration = 0.32,
  }) : super(position: position, size: Vector2(maxRadius * 2, maxRadius * 2), anchor: Anchor.center);

  @override
  void onMount() {
    super.onMount();
    AudioManager.playExplosion();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    final progress = (_timer / duration).clamp(0.0, 1.0);

    // Daño en área instantáneo al inicio de la explosión
    if (!_hasDamaged && progress >= 0.15) {
      _hasDamaged = true;
      final player = game.player;
      if (player.isAlive) {
        final distSq = (player.position - position).length2;
        if (distSq <= maxRadius * maxRadius) {
          player.takeDamage(damage);
        }
      }
    }

    if (_timer >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_timer / duration).clamp(0.0, 1.0);
    final currentRadius = maxRadius * progress;
    final alpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);

    final center = Offset(size.x / 2, size.y / 2);

    _outerPaint.color = Color.fromARGB(alpha, 255, 61, 0);
    _corePaint.color = Color.fromARGB((alpha * 0.4).toInt(), 255, 214, 0);

    canvas.drawCircle(center, currentRadius, _corePaint);
    canvas.drawCircle(center, currentRadius, _outerPaint);
  }
}
