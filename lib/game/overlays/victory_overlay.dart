import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../dungeon_game.dart';

class VictoryOverlay extends StatelessWidget {
  final DungeonGame game;
  final VoidCallback onNextStage;
  final VoidCallback onReturnToMenu;

  const VictoryOverlay({
    super.key,
    required this.game,
    required this.onNextStage,
    required this.onReturnToMenu,
  });

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final chapter = ((game.journeyStage - 1) ~/ 4) + 1;
    final stageInChapter = ((game.journeyStage - 1) % 4) + 1;
    final isBossStage = game.targetDurationSeconds == 600 || stageInChapter == 4;

    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1522).withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono triunfante
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF6D00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium, color: Colors.black87, size: 38),
              ),
              const SizedBox(height: 12),

              // Título de Victoria
              const Text(
                '¡VICTORIA ALCANZADA!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  shadows: [
                    Shadow(blurRadius: 10, color: Color(0xFFFF6D00)),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Badge de Capítulo y Etapa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2638),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
                ),
                child: Text(
                  isBossStage
                      ? 'CAPÍTULO $chapter · ¡JEFE DERROTADO!'
                      : 'CAPÍTULO $chapter · ETAPA $stageInChapter COMPLETADA',
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tarjetas de Estadísticas
              _statRow('Tiempo de Batalla', _formatTime(game.elapsedTime.toInt()), Icons.timer),
              _statRow('Enemigos Aniquilados', '${game.enemiesSlain}', Icons.sports_kabaddi),
              _statRow('Nivel de Héroe', 'Nivel ${game.playerLevelNotifier.value}', Icons.upgrade),
              _statRow('Oro Recolectado', '+${game.goldEarned} monedas', Icons.monetization_on, isGold: true),
              if (game.victoryBonusGold > 0)
                _statRow(
                  'Bonus de Etapa Superada',
                  '+${game.victoryBonusGold} ORO EXTRA',
                  Icons.card_giftcard,
                  isBonus: true,
                ),

              const SizedBox(height: 22),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        AudioManager.pauseBgm();
                        onReturnToMenu();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('MENÚ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onNextStage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'SIGUIENTE ETAPA',
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, {bool isGold = false, bool isBonus = false}) {
    final color = isBonus
        ? const Color(0xFF00FF88)
        : (isGold ? const Color(0xFFFFD700) : Colors.white);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isBonus
                ? const Color(0xFF00FF88)
                : (isGold ? const Color(0xFFFFD700) : Colors.white60),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isBonus ? const Color(0xFF00FF88) : Colors.white70,
              fontSize: 13,
              fontWeight: isBonus ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
