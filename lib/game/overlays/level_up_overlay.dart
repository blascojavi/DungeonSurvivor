import 'dart:math';
import 'package:flutter/material.dart';
import '../dungeon_game.dart';

class SkillCard {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  SkillCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class LevelUpOverlay extends StatefulWidget {
  final DungeonGame game;

  const LevelUpOverlay({super.key, required this.game});

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> {
  late List<SkillCard> availableSkills;

  final List<SkillCard> _allSkills = [
    SkillCard(
      id: 'damage',
      title: 'Furia Destructiva',
      description: '+25% de Daño para tus proyectiles mágicos',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFF3D00),
    ),
    SkillCard(
      id: 'fire_rate',
      title: 'Cadencia Arcana',
      description: '+18% de Velocidad de Ataque automático',
      icon: Icons.flash_on,
      color: const Color(0xFFFFD600),
    ),
    SkillCard(
      id: 'speed',
      title: 'Zancada Veloz',
      description: '+15% de Velocidad de Movimiento del héroe',
      icon: Icons.directions_run,
      color: const Color(0xFF00E5FF),
    ),
    SkillCard(
      id: 'heal_and_health',
      title: 'Bendición Vital',
      description: '+25 Salud Máxima y cura el 50% de la vida actual',
      icon: Icons.favorite,
      color: const Color(0xFF00E676),
    ),
    SkillCard(
      id: 'magnet',
      title: 'Vórtice Magnético',
      description: '+40% Radio de absorción de gemas y tesoros',
      icon: Icons.all_inclusive,
      color: const Color(0xFFE040FB),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Elegir 3 habilidades al azar sin repetir
    final shuffled = List<SkillCard>.from(_allSkills)..shuffle(Random());
    availableSkills = shuffled.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF10141E).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡SUBIDA DE NIVEL!',
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Elige una bendición para tu héroe:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 18),

            ...availableSkills.map((skill) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => widget.game.applySkillUpgrade(skill.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2234),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: skill.color.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: skill.color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(skill.icon, color: skill.color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skill.title,
                                style: TextStyle(
                                  color: skill.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                skill.description,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
