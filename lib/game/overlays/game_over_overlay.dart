import 'package:flutter/material.dart';
import '../dungeon_game.dart';

class GameOverOverlay extends StatelessWidget {
  final DungeonGame game;
  final VoidCallback onReturnToMenu;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onReturnToMenu,
    required this.onRestart,
  });

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF10141E).withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF2A4B).withValues(alpha: 0.7), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2A4B).withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_very_dissatisfied, color: Color(0xFFFF2A4B), size: 54),
            const SizedBox(height: 8),
            const Text(
              '¡FIN DE LA PARTIDA!',
              style: TextStyle(
                color: Color(0xFFFF2A4B),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'El héroe ha caído en las sombras...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Tarjetas de estadísticas
            _statRow('Tiempo Sobrevivido', _formatTime(game.elapsedTime.toInt()), Icons.timer),
            _statRow('Enemigos Eliminados', '${game.enemiesSlain}', Icons.sports_kabaddi),
            _statRow('Oleada Alcanzada', '${game.currentWave}', Icons.shield),
            _statRow('Oro Guardado en BBDD', '+${game.goldEarned} monedas', Icons.monetization_on, isGold: true),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReturnToMenu,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('MENÚ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                    child: const Text('REINTENTAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, {bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: isGold ? const Color(0xFFFFD700) : Colors.white60, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isGold ? const Color(0xFFFFD700) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
