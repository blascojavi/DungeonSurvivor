import 'package:flutter/material.dart';
import '../dungeon_game.dart';

class HudOverlay extends StatelessWidget {
  final DungeonGame game;

  const HudOverlay({super.key, required this.game});

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Barra de Experiencia superior (Glow verde)
            ValueListenableBuilder<double>(
              valueListenable: game.expProgressNotifier,
              builder: (context, exp, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: exp,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF1E2638),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF88)),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Fila superior: Vida, Nivel, Tiempo, Oro y Pausa
            Row(
              children: [
                // Nivel actual
                ValueListenableBuilder<int>(
                  valueListenable: game.playerLevelNotifier,
                  builder: (context, level, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2979FF),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          boxBorderEffect(),
                        ],
                      ),
                      child: Text(
                        'NV $level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Barra de Vida
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: game.playerHpNotifier,
                    builder: (context, hp, _) {
                      return ValueListenableBuilder<double>(
                        valueListenable: game.playerMaxHpNotifier,
                        builder: (context, maxHp, _) {
                          final ratio = (hp / maxHp).clamp(0.0, 1.0);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 20,
                                  backgroundColor: const Color(0xFF2B1313),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF2A4B)),
                                ),
                              ),
                              Text(
                                '${hp.toInt()} / ${maxHp.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Contador de Oro
                ValueListenableBuilder<int>(
                  valueListenable: game.goldNotifier,
                  builder: (context, gold, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2638).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$gold',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Cronómetro de supervivencia
                ValueListenableBuilder<int>(
                  valueListenable: game.timeSecondsNotifier,
                  builder: (context, seconds, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2638).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTime(seconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxShadow boxBorderEffect() {
    return BoxShadow(
      color: const Color(0xFF2979FF).withValues(alpha: 0.4),
      blurRadius: 6,
      spreadRadius: 1,
    );
  }
}
