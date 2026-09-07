import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../data/database/database.dart';
import '../data/repositories/game_repository.dart';
import 'game_screen.dart';
import 'records_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final GameRepository repository;

  const MainMenuScreen({super.key, required this.repository});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _getBossNameForChapter(int chapter) {
    switch ((chapter - 1) % 6) {
      case 0:
        return 'Ignis · El Coloso de Ceniza';
      case 1:
        return 'Gorgoroth · Titán de Hueso';
      case 2:
        return 'Vespertina · Matriarca del Enjambre';
      case 3:
        return 'Archimago Valerius · El Hereje';
      case 4:
        return 'Xul\'Krag · Devorador de Sombras';
      case 5:
      default:
        return 'Lord Malakor · Señor del Abismo';
    }
  }

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Fila de recursos superiores (Oro y Gemas guardados en BBDD local)
                  StreamBuilder<PlayerProfile>(
                    stream: widget.repository.watchPlayerProfile(),
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

                  const SizedBox(height: 20),

                  // Emblema Central: Sello Arcano Sangriento con Rotación Continua como en la Web
                  Center(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF1744).withValues(alpha: 0.35),
                            blurRadius: 36,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: RotationTransition(
                        turns: _rotationController,
                        child: Image.asset(
                          'assets/images/arcane_blood_circle.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Título del juego
                  const Text(
                    'SHADOW VAULT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(blurRadius: 16, color: Color(0xFF2979FF), offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'DUNGEON SURVIVOR 2D',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge de Dificultad Activa
                  StreamBuilder<GameSettingsTableData>(
                    stream: widget.repository.watchSettings(),
                    builder: (context, snapshot) {
                      final mode = snapshot.data?.difficultyMode ?? 'nightmare';
                      final isNightmare = mode == 'nightmare';

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(repository: widget.repository),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isNightmare
                                ? const Color(0xFFFF2A4B).withValues(alpha: 0.15)
                                : const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isNightmare
                                  ? const Color(0xFFFF2A4B).withValues(alpha: 0.4)
                                  : const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isNightmare ? Icons.dangerous : Icons.shield_outlined,
                                size: 14,
                                color: isNightmare ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isNightmare ? 'MODO PESADILLA ACTIVO' : 'MODO NOVATO ACTIVO',
                                style: TextStyle(
                                  color: isNightmare ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.settings,
                                size: 12,
                                color: (isNightmare ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF)).withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Tarjeta reactiva del "Viaje del Héroe"
                  StreamBuilder<PlayerProfile>(
                    stream: widget.repository.watchPlayerProfile(),
                    builder: (context, snapshot) {
                      final stage = snapshot.data?.journeyStage ?? 1;
                      final chapter = ((stage - 1) ~/ 4) + 1;
                      final stageInChapter = ((stage - 1) % 4) + 1;
                      final isBossStage = stageInChapter == 4;
                      final skirmishDuration = (stageInChapter % 2 == 1) ? 180 : 300;
                      final duration = isBossStage ? 600 : skirmishDuration;
                      final bossName = _getBossNameForChapter(chapter);

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131A29).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isBossStage
                                ? const Color(0xFFFF2A4B).withValues(alpha: 0.7)
                                : const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isBossStage ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF)).withValues(alpha: 0.15),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isBossStage ? Icons.warning_amber_rounded : Icons.explore,
                                  size: 16,
                                  color: isBossStage ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'EL VIAJE DEL HÉROE  •  CAPÍTULO $chapter',
                                  style: TextStyle(
                                    color: isBossStage ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Etapa $stageInChapter de 4',
                                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBossStage
                                  ? '¡BATALLA CONTRA EL JEFE (10 MIN)!'
                                  : 'ESCARAMUZA EN LA MAZMORRA (${duration ~/ 60} MIN)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBossStage
                                  ? 'Enfrentamiento inminente: $bossName'
                                  : 'Resiste el asedio y purifica la cámara antes de avanzar.',
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Botón principal: VIAJE DEL HÉROE
                  StreamBuilder<PlayerProfile>(
                    stream: widget.repository.watchPlayerProfile(),
                    builder: (context, snapshot) {
                      final stage = snapshot.data?.journeyStage ?? 1;
                      final stageInChapter = ((stage - 1) % 4) + 1;
                      final isBossStage = stageInChapter == 4;
                      final duration = isBossStage ? 600 : ((stageInChapter % 2 == 1) ? 180 : 300);

                      return _MenuButton(
                        label: isBossStage ? 'DESAFIAR AL JEFE (ETAPA $stage)' : 'VIAJE DEL HÉROE (ETAPA $stage)',
                        icon: isBossStage ? Icons.local_fire_department : Icons.play_arrow_rounded,
                        isPrimary: true,
                        badgeText: '${duration ~/ 60} MIN',
                        onTap: () async {
                          final upgrades = await widget.repository.getUpgrades();
                          final settings = await widget.repository.getSettings();
                          if (context.mounted) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  repository: widget.repository,
                                  upgrades: upgrades,
                                  isLeftHanded: settings.isLeftHanded,
                                  difficultyMode: settings.difficultyMode,
                                  gameMode: 'journey',
                                  journeyStage: stage,
                                  targetDurationSeconds: duration,
                                ),
                              ),
                            );
                            AudioManager.resumeBgm();
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Botón: MODO SUPERVIVENCIA INFINITA
                  _MenuButton(
                    label: 'SUPERVIVENCIA INFINITA',
                    icon: Icons.all_inclusive,
                    isPrimary: false,
                    badgeText: 'SIN TIEMPO',
                    onTap: () async {
                      final upgrades = await widget.repository.getUpgrades();
                      final settings = await widget.repository.getSettings();
                      if (context.mounted) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              repository: widget.repository,
                              upgrades: upgrades,
                              isLeftHanded: settings.isLeftHanded,
                              difficultyMode: settings.difficultyMode,
                              gameMode: 'survivor',
                              journeyStage: 1,
                              targetDurationSeconds: null,
                            ),
                          ),
                        );
                        AudioManager.resumeBgm();
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Botón: TALLER DE MEJORAS
                  _MenuButton(
                    label: 'TALLER DE MEJORAS',
                    icon: Icons.shield,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ShopScreen(repository: widget.repository),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Botón: SALÓN DE RÉCORDS
                  _MenuButton(
                    label: 'RÉCORDS Y ESTADÍSTICAS',
                    icon: Icons.emoji_events,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecordsScreen(repository: widget.repository),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Botón: AJUSTES Y DIFICULTAD
                  _MenuButton(
                    label: 'AJUSTES Y DIFICULTAD',
                    icon: Icons.tune,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(repository: widget.repository),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

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
  final String? badgeText;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
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
            Icon(icon, size: 20, color: isPrimary ? Colors.white : const Color(0xFF00E5FF)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.0,
                  color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    color: isPrimary ? const Color(0xFF00E5FF) : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
