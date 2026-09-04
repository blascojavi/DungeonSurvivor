import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DungeonMapComponent extends PositionComponent {
  static const double mapWidth = 1600;
  static const double mapHeight = 1600;
  static const double tileSize = 80;

  DungeonMapComponent()
      : super(
          position: Vector2.zero(),
          size: Vector2(mapWidth, mapHeight),
          priority: -10, // Renderizar al fondo
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fondo oscuro de mazmorra
    final bgPaint = Paint()..color = const Color(0xFF10141E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // Baldosas de piedra con cuadrícula estilizada
    final tileBorderPaint = Paint()
      ..color = const Color(0xFF1E2638)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double x = 0; x < size.x; x += tileSize) {
      for (double y = 0; y < size.y; y += tileSize) {
        canvas.drawRect(Rect.fromLTWH(x, y, tileSize, tileSize), tileBorderPaint);

        // Detalles aleatorios en algunas baldosas (grietas / runas)
        if ((x + y) % (tileSize * 4) == 0) {
          final runePaint = Paint()
            ..color = const Color(0x1400E5FF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawCircle(Offset(x + tileSize / 2, y + tileSize / 2), tileSize * 0.25, runePaint);
        }
      }
    }

    // Muros perimetrales luminosos (Límite del área jugable)
    final wallGlowPaint = Paint()
      ..color = const Color(0x66FF3D00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawRect(Rect.fromLTWH(4, 4, size.x - 8, size.y - 8), wallGlowPaint);

    final wallPaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(Rect.fromLTWH(4, 4, size.x - 8, size.y - 8), wallPaint);
  }
}
