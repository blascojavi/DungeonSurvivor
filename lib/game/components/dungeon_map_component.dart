import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../dungeon_game.dart';

class DungeonMapComponent extends PositionComponent with HasGameReference<DungeonGame> {
  static const double mapWidth = 1600;
  static const double mapHeight = 1600;
  static const double textureTileSize = 320;

  ui.Picture? _cachedMapPicture;

  DungeonMapComponent()
      : super(
          position: Vector2.zero(),
          size: Vector2(mapWidth, mapHeight),
          priority: -10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final floorImage = await game.images.load('dungeon_floor.png');
      ui.Image? circleImage;
      try {
        circleImage = await game.images.load('arcane_blood_circle.png');
      } catch (_) {}
      _cacheMap(floorImage, circleImage);
    } catch (_) {
      _cacheFallbackMap();
    }
  }

  void _cacheMap(ui.Image floorImage, ui.Image? circleImage) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, mapWidth, mapHeight));

    // 1. Fondo base oscuro
    canvas.drawRect(const Rect.fromLTWH(0, 0, mapWidth, mapHeight), Paint()..color = const Color(0xFF0F1420));

    // 2. Mapeado de baldosas de piedra auténticas de mazmorra (5x5 repeticiones de 320px)
    final srcRect = Rect.fromLTWH(0, 0, floorImage.width.toDouble(), floorImage.height.toDouble());
    final tilePaint = Paint()..filterQuality = FilterQuality.medium;

    for (double x = 0; x < mapWidth; x += textureTileSize) {
      for (double y = 0; y < mapHeight; y += textureTileSize) {
        final dstRect = Rect.fromLTWH(x, y, textureTileSize, textureTileSize);
        canvas.drawImageRect(floorImage, srcRect, dstRect, tilePaint);
      }
    }

    // 3. Tinte atmosférico para mazmorra oscura (Dark Fantasy Ambient Tint)
    final tintPaint = Paint()..color = const Color(0x33000511);
    canvas.drawRect(const Rect.fromLTWH(0, 0, mapWidth, mapHeight), tintPaint);

    // 4. Gran Sello Arcano Rúnico Sangriento en el centro de la mazmorra
    final center = const Offset(mapWidth / 2, mapHeight / 2);
    if (circleImage != null) {
      final circleSrc = Rect.fromLTWH(0, 0, circleImage.width.toDouble(), circleImage.height.toDouble());
      final circleDst = Rect.fromCenter(center: center, width: 440, height: 440);
      canvas.drawImageRect(circleImage, circleSrc, circleDst, Paint()..filterQuality = FilterQuality.medium);

      // Halo carmesí y cian sutil alrededor del sello
      final glowPaint = Paint()
        ..color = const Color(0x18FF1744)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14;
      canvas.drawCircle(center, 220, glowPaint);
    } else {
      // Fallback si no carga la imagen
      final runeRingOuter = Paint()
        ..color = const Color(0x2800E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, 180, runeRingOuter);
    }

    // 5. Murallas perimetrales de piedra maciza y runas incandescentes de contención
    final wallBorderOuter = Paint()
      ..color = const Color(0xFF070A10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;
    canvas.drawRect(const Rect.fromLTWH(12, 12, mapWidth - 24, mapHeight - 24), wallBorderOuter);

    final wallEmbers = Paint()
      ..color = const Color(0x77FF3D00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(const Rect.fromLTWH(24, 24, mapWidth - 48, mapHeight - 48), wallEmbers);

    final wallGlow = Paint()
      ..color = const Color(0x22FF5722)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawRect(const Rect.fromLTWH(24, 24, mapWidth - 48, mapHeight - 48), wallGlow);

    _cachedMapPicture = recorder.endRecording();
  }

  void _cacheFallbackMap() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, mapWidth, mapHeight));
    canvas.drawRect(const Rect.fromLTWH(0, 0, mapWidth, mapHeight), Paint()..color = const Color(0xFF0F1420));
    _cachedMapPicture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_cachedMapPicture != null) {
      canvas.drawPicture(_cachedMapPicture!);
    }
  }

  @override
  void onRemove() {
    _cachedMapPicture?.dispose();
    super.onRemove();
  }
}
