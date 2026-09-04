import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/repositories/game_repository.dart';

class RecordsScreen extends StatelessWidget {
  final GameRepository repository;

  const RecordsScreen({super.key, required this.repository});

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141A29),
        title: const Text(
          'SALÓN DE RÉCORDS LOCALES',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: FutureBuilder<List<RunHistory>>(
        future: repository.getHighScores(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
          }

          final records = snapshot.data!;
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_edu, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no hay expediciones registradas.',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Entra a la mazmorra para forjar tu leyenda!',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final run = records[index];
              final isFirst = index == 0;

              return Card(
                color: isFirst ? const Color(0xFF1F293D) : const Color(0xFF161E2E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isFirst ? const Color(0xFFFFD700) : Colors.transparent,
                    width: isFirst ? 1.5 : 0,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isFirst ? const Color(0xFFFFD700) : const Color(0xFF2979FF),
                    foregroundColor: Colors.black,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    'Puntuación: ${run.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Tiempo: ${_formatTime(run.survivedSeconds)}  •  Bajas: ${run.enemiesSlain}  •  Oleada: ${run.waveReached}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${run.goldEarned}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
