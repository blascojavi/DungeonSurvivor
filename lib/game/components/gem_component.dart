import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../dungeon_game.dart';
import 'player_component.dart';

enum GemType { exp, gold }

class GemComponent extends PositionComponent with HasGameReference<DungeonGame> {
  final GemType type;
  final int value;
  bool isAttracted = false;
  double attractSpeed = 160;

  static final Paint _expGlow = Paint()..color = const Color(0x3300FF88);
  static final Paint _expColor = Paint()..color = const Color(0xFF00FF88);
  static final Paint _goldGlow = Paint()..color = const Color(0x33FFD700);
  static final Paint _goldColor = Paint()..color = const Color(0xFFFFD700);
  static final Paint _highlight = Paint()..color = const Color(0xCCFFFFFF);

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
  void onMount() {
    super.onMount();
    game.activeGems.add(this);
  }

  @override
  void onRemove() {
    game.activeGems.remove(this);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = game.player;
    if (!player.isAlive) return;

    if (isAttracted) {
      final toPlayer = player.position - position;
      final distSq = toPlayer.length2;
      if (distSq <= 26 * 26) {
        _collect(player);
        return;
      }
      final distance = sqrt(distSq);
      attractSpeed += 750 * dt;
      position += (toPlayer / distance) * (attractSpeed * dt);
    } else {
      // Recogida por contacto directo sin imán
      final distSq = (player.position - position).length2;
      if (distSq <= 24 * 24) {
        _collect(player);
      }
    }
  }

  void _collect(PlayerComponent player) {
    AudioManager.playGem();
    if (type == GemType.exp) {
      player.addExp(value);
    } else if (type == GemType.gold) {
      game.addGold(value);
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final isExp = type == GemType.exp;
    final center = Offset(size.x / 2, size.y / 2);

    // Halo ligero sin MaskFilter.blur para máximo rendimiento
    canvas.drawCircle(center, size.x / 2 + 2, isExp ? _expGlow : _goldGlow);

    // Diamante / Gema
    final path = Path()
      ..moveTo(size.x / 2, 1)
      ..lineTo(size.x - 1, size.y / 2)
      ..lineTo(size.x / 2, size.y - 1)
      ..lineTo(1, size.y / 2)
      ..close();

    canvas.drawPath(path, isExp ? _expColor : _goldColor);
    canvas.drawCircle(Offset(size.x / 2, size.y / 3), 2, _highlight);
  }

  void attract() {
    isAttracted = true;
  }
}
