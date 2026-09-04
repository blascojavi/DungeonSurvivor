import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/repositories/game_repository.dart';
import 'game_screen.dart';
import 'records_screen.dart';
import 'shop_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final GameRepository repository;

  const MainMenuScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      body: Stack(
        children: [
          // Fondo ambiental con gradiente místico
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  Color(0xFF192238),
                  Color(0xFF090C12),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Fila de recursos superiores (Oro y Gemas guardados en BBDD local)
                  StreamBuilder<PlayerProfile>(
                    stream: repository.watchPlayerProfile(),
                    builder: (context, snapshot) {
                      final gold = snapshot.data?.goldCoins ?? 0;
                      final totalKills = snapshot.data?.totalKills ?? 0;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141B2B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sports_kabaddi, color: Color(0xFF00E5FF), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Bajas: $totalKills',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141B2B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '$gold Oro',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Emblema e Ícono central
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shield, color: Colors.white, size: 54),
                  ),
                  const SizedBox(height: 24),

                  // Título del juego
                  const Text(
                    'SHADOW VAULT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(blurRadius: 16, color: Color(0xFF2979FF), offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'DUNGEON SURVIVOR 2D',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Botón principal: JUGAR
                  _MenuButton(
                    label: 'ENTRAR A LA MAZMORRA',
                    icon: Icons.play_arrow_rounded,
                    isPrimary: true,
                    onTap: () async {
                      final upgrades = await repository.getUpgrades();
                      final settings = await repository.getSettings();
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              repository: repository,
                              upgrades: upgrades,
                              isLeftHanded: settings.isLeftHanded,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Botón: TALLER DE MEJORAS
                  _MenuButton(
                    label: 'TALLER DE MEJORAS',
                    icon: Icons.shield,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ShopScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Botón: SALÓN DE RÉCORDS
                  _MenuButton(
                    label: 'RÉCORDS Y ESTADÍSTICAS',
                    icon: Icons.emoji_events,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecordsScreen(repository: repository),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Nota de estado de almacenamiento
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_clock, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(width: 6),
                      Text(
                        'Modo 100% Offline  •  Base de Datos SQLite Local',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF2979FF) : const Color(0xFF161E2E),
          foregroundColor: Colors.white,
          elevation: isPrimary ? 8 : 2,
          shadowColor: isPrimary ? const Color(0xFF2979FF).withValues(alpha: 0.5) : Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isPrimary ? const Color(0xFF00E5FF) : const Color(0xFF2C3954),
              width: 1.2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: isPrimary ? Colors.white : const Color(0xFF00E5FF)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1.2,
                color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
