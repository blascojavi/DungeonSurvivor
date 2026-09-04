import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DungeonMapComponent extends PositionComponent {
  static const double mapWidth = 1600;
  static const double mapHeight = 1600;
  static const double tileSize = 80;

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
    _cacheMap();
  }

  void _cacheMap() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, mapWidth, mapHeight));

    // 1. Fondo oscuro
    final bgPaint = Paint()..color = const Color(0xFF0F1420);
    canvas.drawRect(const Rect.fromLTWH(0, 0, mapWidth, mapHeight), bgPaint);

    // 2. Baldosas grabadas una sola vez en la GPU
    final tilePaint = Paint()
      ..color = const Color(0xFF1B2336)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final runePaint = Paint()
      ..color = const Color(0x1200E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double x = 0; x < mapWidth; x += tileSize) {
      for (double y = 0; y < mapHeight; y += tileSize) {
        canvas.drawRect(Rect.fromLTWH(x, y, tileSize, tileSize), tilePaint);

        if ((x + y) % (tileSize * 4) == 0) {
          canvas.drawCircle(Offset(x + tileSize / 2, y + tileSize / 2), tileSize * 0.22, runePaint);
        }
      }
    }

    // 3. Muro perimetral luminoso sin filtros de desenfoque costosos
    final outerWallPaint = Paint()
      ..color = const Color(0x55FF3D00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawRect(const Rect.fromLTWH(4, 4, mapWidth - 8, mapHeight - 8), outerWallPaint);

    final innerWallPaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(const Rect.fromLTWH(4, 4, mapWidth - 8, mapHeight - 8), innerWallPaint);

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
