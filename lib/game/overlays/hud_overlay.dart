import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../dungeon_game.dart';

class HudOverlay extends StatefulWidget {
  final DungeonGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return SafeArea(
      child: Stack(
        children: [
          // 1. Header superior: Experiencia, Vida, Nivel, Oro y Cronómetro
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 8),

                // Fila superior de estadísticas
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
                              BoxShadow(
                                color: const Color(0xFF2979FF).withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
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
                    const SizedBox(width: 10),

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
                    const SizedBox(width: 8),

                    // Botón de Pausa / Ajustes
                    InkWell(
                      onTap: () {
                        game.pauseEngine();
                        AudioManager.pauseBgm();
                        game.overlays.add('Pause');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2638).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.pause, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),

                // 2. Barra de Vida Épica del Jefe de Mazmorra (Solo visible cuando hay Jefe)
                ValueListenableBuilder<bool>(
                  valueListenable: game.isBossAliveNotifier,
                  builder: (context, isBossAlive, _) {
                    if (!isBossAlive) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14080B).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF1744).withValues(alpha: 0.8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF1744).withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5252), size: 16),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<String>(
                                valueListenable: game.bossNameNotifier,
                                builder: (context, name, _) {
                                  return Text(
                                    name,
                                    style: const TextStyle(
                                      color: Color(0xFFFF5252),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ValueListenableBuilder<double>(
                            valueListenable: game.bossHpNotifier,
                            builder: (context, ratio, _) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 12,
                                  backgroundColor: const Color(0xFF2A0D13),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF1744)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Botón Táctil de Habilidad Definitiva (Ultimate)
          // Se ubica a la derecha si es diestro (joystick a la izquierda) o a la izquierda si es zurdo
          Positioned(
            bottom: 36,
            right: game.isLeftHanded ? null : 28,
            left: game.isLeftHanded ? 28 : null,
            child: ValueListenableBuilder<bool>(
              valueListenable: game.isUltimateReadyNotifier,
              builder: (context, isReady, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: game.ultimateChargeNotifier,
                  builder: (context, charge, _) {
                    final button = GestureDetector(
                      onTap: () {
                        if (isReady) {
                          game.triggerPlayerUltimate();
                        }
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isReady ? const Color(0xFF00E5FF) : const Color(0xFF161F33),
                          border: Border.all(
                            color: isReady ? Colors.white : const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            width: isReady ? 3 : 1.5,
                          ),
                          boxShadow: isReady
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                                    blurRadius: 16,
                                    spreadRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Anillo de progreso si se está cargando
                            if (!isReady)
                              SizedBox(
                                width: 66,
                                height: 66,
                                child: CircularProgressIndicator(
                                  value: charge,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                ),
                              ),

                            // Icono de habilidad definitiva
                            Icon(
                              Icons.auto_awesome,
                              color: isReady ? Colors.black : Colors.white54,
                              size: 32,
                            ),

                            // Etiqueta de estado
                            Positioned(
                              bottom: 6,
                              child: Text(
                                isReady ? '¡NOVA!' : '${(charge * 20).toInt()}/20',
                                style: TextStyle(
                                  color: isReady ? Colors.black : Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (isReady) {
                      return ScaleTransition(scale: _pulseAnimation, child: button);
                    }
                    return button;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
