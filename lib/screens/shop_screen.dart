import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/repositories/game_repository.dart';

class ShopScreen extends StatelessWidget {
  final GameRepository repository;

  const ShopScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141A29),
        title: const Text(
          'TALLER DE MEJORAS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          StreamBuilder<PlayerProfile>(
            stream: repository.watchPlayerProfile(),
            builder: (context, snapshot) {
              final gold = snapshot.data?.goldCoins ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2638),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$gold',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector de Ergonomía: Zurdo o Diestro (Solicitado por el usuario)
            StreamBuilder<GameSettingsTableData>(
              stream: repository.watchSettings(),
              builder: (context, settingsSnapshot) {
                final isLeftHanded = settingsSnapshot.data?.isLeftHanded ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141B2B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.sports_esports, color: Color(0xFF00E5FF), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'MODO DE CONTROL (JOYSTICK)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLeftHanded
                            ? 'Actualmente: Modo ZURDO (Joystick posicionado a la DERECHA).'
                            : 'Actualmente: Modo DIESTRO (Joystick posicionado a la IZQUIERDA).',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _HandednessOption(
                              label: 'DIESTRO',
                              sublabel: 'Joystick Izquierda',
                              icon: Icons.front_hand,
                              isSelected: !isLeftHanded,
                              onTap: () => repository.setLeftHanded(false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HandednessOption(
                              label: 'ZURDO',
                              sublabel: 'Joystick Derecha',
                              icon: Icons.back_hand,
                              isSelected: isLeftHanded,
                              onTap: () => repository.setLeftHanded(true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'MEJORAS PERMANENTES DE ATRIBUTOS',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // 2. Lista de mejoras permanentes
            StreamBuilder<List<PermanentUpgrade>>(
              stream: repository.watchUpgrades(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                    ),
                  );
                }

                final upgrades = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upgrades.length,
                  itemBuilder: (context, index) {
                    final upgrade = upgrades[index];
                    final isMaxed = upgrade.currentLevel >= upgrade.maxLevel;
                    final cost = (upgrade.baseCost * (upgrade.currentLevel == 0 ? 1 : (upgrade.costMultiplier * upgrade.currentLevel))).round();

                    return Card(
                      color: const Color(0xFF161E2E),
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: borderBorderSide(upgrade.currentLevel > 0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(_getUpgradeIcon(upgrade.upgradeId), color: const Color(0xFF00E5FF), size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        upgrade.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        upgrade.description,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'NV ${upgrade.currentLevel}/${upgrade.maxLevel}',
                                  style: TextStyle(
                                    color: isMaxed ? const Color(0xFF00FF88) : const Color(0xFF00E5FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Barra de progreso del nivel
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: upgrade.currentLevel / upgrade.maxLevel,
                                minHeight: 6,
                                backgroundColor: const Color(0xFF10141E),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isMaxed ? const Color(0xFF00FF88) : const Color(0xFF2979FF),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Botón de compra / mejora
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: isMaxed
                                    ? null
                                    : () async {
                                        final success = await repository.purchaseUpgrade(upgrade);
                                        if (!success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('¡Oro insuficiente en la cámara del tesoro!'),
                                              backgroundColor: Color(0xFFFF2A4B),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                icon: Icon(
                                  isMaxed ? Icons.check_circle : Icons.monetization_on,
                                  size: 18,
                                  color: isMaxed ? Colors.white54 : const Color(0xFFFFD700),
                                ),
                                label: Text(
                                  isMaxed ? 'MÁXIMO' : '$cost ORO',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isMaxed ? const Color(0xFF1E2638) : const Color(0xFF2979FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
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
          ],
        ),
      ),
    );
  }

  BorderSide borderBorderSide(bool isActive) {
    return BorderSide(
      color: isActive ? const Color(0xFF2979FF).withValues(alpha: 0.5) : Colors.transparent,
      width: 1.5,
    );
  }

  IconData _getUpgradeIcon(String id) {
    switch (id) {
      case 'max_hp':
        return Icons.favorite;
      case 'attack_power':
        return Icons.local_fire_department;
      case 'move_speed':
        return Icons.directions_run;
      case 'magnet_radius':
        return Icons.all_inclusive;
      default:
        return Icons.star;
    }
  }
}

class _HandednessOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _HandednessOption({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2979FF).withValues(alpha: 0.25) : const Color(0xFF10141E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
